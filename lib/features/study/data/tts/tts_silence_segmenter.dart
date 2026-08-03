import 'dart:typed_data';

/// Kết quả tách từ từ audio: một từ (word) ứng với khoảng thời gian
/// trong toàn bộ audio, đo bằng sample index.
class TtsDetectedWord {
  const TtsDetectedWord({
    required this.startSample,
    required this.endSample,
    required this.wordIndex,
  });

  /// Sample index bắt đầu (inclusive).
  final int startSample;

  /// Sample index kết thúc (exclusive).
  final int endSample;

  /// Thứ tự từ trong chuỗi text gốc (0-based), theo tokenizer tách
  /// whitespace/punctuation — dùng để map sang UTF-16 offset của text.
  final int wordIndex;
}

/// Tách từ bằng phát hiện silence trên samples của sherpa-onnx
/// (`GeneratedAudio.samples` + `sampleRate`).
///
/// Vì `GeneratedAudio` không có token/timing, đây là cách nhẹ và
/// deterministic để suy ra word boundary: cùng model + text + speed →
/// cùng samples → cùng kết quả. Timing không còn phụ thuộc "đo lúc play".
///
/// Thuật toán:
/// 1. Tính RMS theo frame (cửa sổ cố định ~10ms) để chống nhiễu lẻ tẻ.
/// 2. Xác định ngưỡng silence tuyệt đối từ `rmsSilenceThreshold` (config
///    hằng, hiệu chỉnh theo đặc tính model Piper/VITS).
/// 3. Frame có RMS <= ngưỡng là silence; gộp silence liên tiếp thành gap.
/// 4. Gap dài >= `minGapSamples` thì coi là ranh giới giữa 2 từ.
/// 5. Nếu số từ tách được khác số token trong text (heuristic tokenizer),
///    fallback chia đều theo số token — vẫn deterministic, không phải
///    "đo lúc play".
class TtsSilenceSegmenter {
  const TtsSilenceSegmenter({
    this.frameDurationMs = 10,
    this.rmsSilenceThreshold = 0.01,
    this.minGapMs = 80,
  });

  /// Độ dài frame RMS (ms).
  final double frameDurationMs;

  /// Ngưỡng RMS (amplitude chuẩn hoá [-1, 1]) dưới đó coi là silence.
  final double rmsSilenceThreshold;

  /// Gap silence tối thiểu (ms) để coi là ranh giới giữa 2 từ.
  final double minGapMs;

  /// Tách audio thành các từ.
  ///
  /// [expectedWordCount] là số token trong text (đếm theo tokenizer);
  /// dùng để fallback khi silence detection lệch.
  List<TtsDetectedWord> segment(
    Float32List samples, {
    required int sampleRate,
    required int expectedWordCount,
  }) {
    if (samples.isEmpty || sampleRate <= 0 || expectedWordCount <= 0) {
      return const [];
    }

    final frameSize = (sampleRate * frameDurationMs / 1000).round().clamp(1, 1 << 30);
    final rmsPerFrame = _computeRmsPerFrame(samples, frameSize);
    final isSilence = List<bool>.filled(rmsPerFrame.length, false);
    for (var i = 0; i < rmsPerFrame.length; i++) {
      isSilence[i] = rmsPerFrame[i] <= rmsSilenceThreshold;
    }

    final minGapFrames = (minGapMs / frameDurationMs).ceil();
    final words = <TtsDetectedWord>[];

    var inWord = false;
    var wordStartSample = 0;
    var silenceRun = 0;

    for (var i = 0; i < isSilence.length; i++) {
      if (!isSilence[i]) {
        if (!inWord) {
          inWord = true;
          wordStartSample = (i * frameSize).clamp(0, samples.length);
        }
        silenceRun = 0;
      } else if (inWord) {
        silenceRun++;
        if (silenceRun >= minGapFrames) {
          words.add(
            TtsDetectedWord(
              startSample: wordStartSample,
              endSample: (i - silenceRun + 1) * frameSize,
              wordIndex: words.length,
            ),
          );
          inWord = false;
          silenceRun = 0;
        }
      }
    }
    if (inWord) {
      words.add(
        TtsDetectedWord(
          startSample: wordStartSample,
          endSample: samples.length,
          wordIndex: words.length,
        ),
      );
    }

    // Fallback khi số từ detect khác số token thật — chia đều duration
    // theo số token (deterministic, dùng được khi model nối âm liền).
    if (words.length != expectedWordCount) {
      return _fallbackEvenSplit(samples.length, expectedWordCount);
    }
    return words;
  }

  /// Fallback: chia đều toàn bộ audio theo số token.
  List<TtsDetectedWord> _fallbackEvenSplit(
    int sampleCount,
    int wordCount,
  ) {
    if (sampleCount <= 0 || wordCount <= 0) return const [];
    final perWord = sampleCount ~/ wordCount;
    final result = <TtsDetectedWord>[];
    for (var i = 0; i < wordCount; i++) {
      final start = i * perWord;
      final end = i == wordCount - 1 ? sampleCount : (i + 1) * perWord;
      result.add(
        TtsDetectedWord(startSample: start, endSample: end, wordIndex: i),
      );
    }
    return result;
  }

  List<double> _computeRmsPerFrame(Float32List samples, int frameSize) {
    final count = (samples.length / frameSize).ceil();
    final rms = List<double>.filled(count, 0);
    for (var f = 0; f < count; f++) {
      var sumSq = 0.0;
      final start = f * frameSize;
      final end = (start + frameSize).clamp(0, samples.length);
      for (var i = start; i < end; i++) {
        final v = samples[i];
        sumSq += v * v;
      }
      rms[f] = (sumSq / (end - start)).clamp(0.0, double.infinity);
    }
    return rms;
  }
}

/// Tokenizer heuristic cho tiếng Anh: tách theo whitespace, bỏ punctuation
/// hai đầu token (giữ offset UTF-16 gốc). Dùng để map word từ silence
/// detection sang `TtsWordRange` (offset trong text gửi vào generate).
class TtsTextTokenizer {
  const TtsTextTokenizer();

  /// Trả về danh sách (start, end) UTF-16 của từng token trong [text].
  List<TtsTextToken> tokenize(String text) {
    final tokens = <TtsTextToken>[];
    var i = 0;
    while (i < text.length) {
      final char = text[i];
      if (_isWhitespace(char)) {
        i++;
        continue;
      }
      final start = i;
      while (i < text.length && !_isWhitespace(text[i])) {
        i++;
      }
      var end = i;
      // Bỏ punctuation hai đầu token (đúng với cách TTS đọc từ).
      while (end > start && _isPunctuation(text[end - 1])) {
        end--;
      }
      var s = start;
      while (s < end && _isPunctuation(text[s])) {
        s++;
      }
      if (s < end) {
        tokens.add(TtsTextToken(start: s, end: end, index: tokens.length));
      }
    }
    return tokens;
  }

  bool _isWhitespace(String ch) => ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r';

  bool _isPunctuation(String ch) =>
      ch == '.' ||
      ch == ',' ||
      ch == '!' ||
      ch == '?' ||
      ch == ';' ||
      ch == ':' ||
      ch == '"' ||
      ch == "'" ||
      ch == '(' ||
      ch == ')' ||
      ch == '[' ||
      ch == ']' ||
      ch == '-' ||
      ch == '—';
}

class TtsTextToken {
  const TtsTextToken({required this.start, required this.end, required this.index});

  /// UTF-16 offset inclusive.
  final int start;

  /// UTF-16 offset exclusive.
  final int end;

  /// Thứ tự token (0-based) — khớp `TtsDetectedWord.wordIndex`.
  final int index;
}
