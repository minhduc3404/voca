import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/data/tts/tts_silence_segmenter.dart';

void main() {
  group('TtsSilenceSegmenter', () {
    const sampleRate = 16000;

    // Tạo samples: [speech][silence gap][speech]... theo danh sách duration (ms).
    Float32List makeAudio(List<int> segmentsMs, {double speechAmp = 0.5}) {
      final totalSamples =
          segmentsMs.fold<int>(0, (sum, ms) => sum + (ms * sampleRate ~/ 1000));
      final buf = Float32List(totalSamples);
      var offset = 0;
      var isSpeech = true;
      for (final ms in segmentsMs) {
        final n = ms * sampleRate ~/ 1000;
        for (var i = 0; i < n; i++) {
          buf[offset + i] = isSpeech ? speechAmp : 0.0;
        }
        offset += n;
        isSpeech = !isSpeech;
      }
      return buf;
    }

    const segmenter = TtsSilenceSegmenter(
      frameDurationMs: 10,
      rmsSilenceThreshold: 0.01,
      minGapMs: 80,
    );

    test('tách đúng 3 từ với gap silence rõ ràng', () {
      // 3 từ, mỗi từ 300ms, gap 150ms.
      final samples = makeAudio([300, 150, 300, 150, 300]);
      final words = segmenter.segment(
        samples,
        sampleRate: sampleRate,
        expectedWordCount: 3,
      );

      expect(words, hasLength(3));
      // word0 bắt đầu từ sample 0
      expect(words[0].startSample, 0);
      // word0 kết thúc trước gap đầu (300ms * 16 = 4800 samples)
      expect(words[0].endSample, 4800);
      // word1 bắt đầu sau gap (4800 + 150ms*16 = 7200)
      expect(words[1].startSample, 7200);
      // từ cuối kết thúc ở cuối audio
      expect(words[2].endSample, samples.length);
      // wordIndex theo thứ tự
      expect(words.map((w) => w.wordIndex), [0, 1, 2]);
    });

    test('fallback chia đều khi số từ detect khác token count', () {
      // Audio liền mạch không gap (1 từ duy nhất) nhưng token count = 3.
      final samples = makeAudio([900]);
      final words = segmenter.segment(
        samples,
        sampleRate: sampleRate,
        expectedWordCount: 3,
      );

      expect(words, hasLength(3));
      // chia đều 3 phần
      final perWord = samples.length ~/ 3;
      expect(words[0].startSample, 0);
      expect(words[0].endSample, perWord);
      expect(words[1].startSample, perWord);
      expect(words[2].endSample, samples.length);
    });

    test('gap ngắn hơn minGapMs không tách từ', () {
      // 2 từ nhưng gap chỉ 50ms (< 80ms) → 1 từ duy nhất.
      final samples = makeAudio([300, 50, 300]);
      final words = segmenter.segment(
        samples,
        sampleRate: sampleRate,
        expectedWordCount: 1,
      );

      expect(words, hasLength(1));
      expect(words.single.startSample, 0);
      expect(words.single.endSample, samples.length);
    });

    test('input rỗng / expectedWordCount 0 → kết quả rỗng', () {
      expect(
        segmenter.segment(
          Float32List(0),
          sampleRate: sampleRate,
          expectedWordCount: 3,
        ),
        isEmpty,
      );
      expect(
        segmenter.segment(
          Float32List(100),
          sampleRate: sampleRate,
          expectedWordCount: 0,
        ),
        isEmpty,
      );
    });
  });

  group('TtsTextTokenizer', () {
    const tokenizer = TtsTextTokenizer();

    test('tokenize câu đơn giản theo whitespace', () {
      final tokens = tokenizer.tokenize('Hello world test');
      expect(tokens, hasLength(3));
      expect(tokens[0].start, 0);
      expect(tokens[0].end, 5);
      expect(tokens[1].start, 6);
      expect(tokens[1].end, 11);
      expect(tokens[2].start, 12);
      expect(tokens[2].end, 16);
    });

    test('bỏ punctuation hai đầu token nhưng giữ offset trong text', () {
      final tokens = tokenizer.tokenize('"Hello," world!');
      expect(tokens, hasLength(2));
      // token 0: từ sample 1..6 ("Hello")
      expect(tokens[0].start, 1);
      expect(tokens[0].end, 6);
      // token 1: "world" tại 9..14 ("world!" có ! ở 14, bị trim)
      expect(tokens[1].start, 9);
      expect(tokens[1].end, 14);
    });

    test('xử lý nhiều whitespace liên tiếp', () {
      final tokens = tokenizer.tokenize('a   b');
      expect(tokens, hasLength(2));
      expect(tokens[0].start, 0);
      expect(tokens[1].start, 4);
      expect(tokens[1].end, 5);
    });

    test('text chỉ punctuation/whitespace → rỗng', () {
      expect(tokenizer.tokenize('   '), isEmpty);
      expect(tokenizer.tokenize('!!!'), isEmpty);
    });
  });
}
