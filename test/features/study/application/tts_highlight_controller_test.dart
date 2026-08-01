import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/lexicon/pronunciation_segment.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/application/tts_highlight_controller.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/tts_service.dart';
import 'package:voca_app/features/study/domain/tts_word_timing_cache_repository.dart';

class _FakeTtsService implements TtsService {
  final controller = StreamController<TtsPlaybackEvent>.broadcast(sync: true);

  @override
  TtsVoice? get selectedVoice => const TtsVoice(name: 'voice', locale: 'en-US');

  @override
  double get speechRate => .5;

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => controller.stream;

  @override
  void dispose() {}

  @override
  Future<List<TtsVoice>> getVoices() async => const [];

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setVoice(TtsVoice voice) async {}

  @override
  Future<void> speak(String text) async {}
}

class _FakeCache implements TtsWordTimingCacheRepository {
  final entries = <String, int>{};

  String _key(int vocabId, int start, int end, String voice, double rate) =>
      '$vocabId:$start:$end:$voice:$rate';

  @override
  Future<int?> getDurationMs({
    required int vocabId,
    required int wordStartOffset,
    required int wordEndOffset,
    required String voiceKey,
    required double speechRate,
  }) async =>
      entries[_key(
        vocabId,
        wordStartOffset,
        wordEndOffset,
        voiceKey,
        speechRate,
      )];

  @override
  Future<void> save(TtsWordTimingCacheEntry entry) async {
    entries[_key(
          entry.vocabId,
          entry.wordStartOffset,
          entry.wordEndOffset,
          entry.voiceKey,
          entry.speechRate,
        )] =
        entry.durationMs;
  }
}

void main() {
  const card = StudyCard(
    id: 1,
    term: 'boarding pass',
    definition: 'thẻ lên máy bay',
    language: 'en',
    phonetic: '/ˈbɔːr.dɪŋ pæs/',
    exampleSentence: 'Show your boarding pass.',
    pronunciationSegments: [
      PronunciationSegment(
        position: 0,
        start: 0,
        end: 5,
        text: 'board',
        ipa: 'bɔːr',
        stress: PronunciationStress.primary,
        timingWeight: 1,
      ),
      PronunciationSegment(
        position: 1,
        start: 5,
        end: 8,
        text: 'ing',
        ipa: 'dɪŋ',
        stress: PronunciationStress.none,
        timingWeight: 1,
      ),
    ],
  );

  test(
    'cache miss highlight segment đầu ngay và completion lưu duration',
    () async {
      final tts = _FakeTtsService();
      final cache = _FakeCache();
      final container = ProviderContainer(
        overrides: [
          ttsServiceProvider.overrideWithValue(tts),
          ttsWordTimingCacheRepositoryProvider.overrideWithValue(cache),
        ],
      );
      addTearDown(() async {
        await tts.controller.close();
        container.dispose();
      });
      final notifier = container.read(ttsHighlightControllerProvider.notifier);
      await notifier.speak(card);
      tts.controller.add(
        const TtsPlaybackEvent.wordBoundary(
          TtsWordRange(text: 'boarding pass', start: 0, end: 8),
        ),
      );

      expect(container.read(ttsHighlightControllerProvider).wordStart, 0);
      expect(
        container.read(ttsHighlightControllerProvider).activeSegmentPosition,
        0,
      );

      await Future<void>.delayed(const Duration(milliseconds: 2));
      tts.controller.add(const TtsPlaybackEvent.completed());
      await Future<void>.delayed(Duration.zero);

      expect(
        await cache.getDurationMs(
          vocabId: 1,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice|en-US',
          speechRate: .5,
        ),
        greaterThan(0),
      );
    },
  );

  test('cancel hoặc error không lưu duration dở dang', () async {
    final tts = _FakeTtsService();
    final cache = _FakeCache();
    final container = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(tts),
        ttsWordTimingCacheRepositoryProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(() async {
      await tts.controller.close();
      container.dispose();
    });

    final notifier = container.read(ttsHighlightControllerProvider.notifier);
    await notifier.speak(card);
    tts.controller.add(
      const TtsPlaybackEvent.wordBoundary(
        TtsWordRange(text: 'boarding pass', start: 0, end: 8),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2));
    tts.controller.add(const TtsPlaybackEvent.cancelled());
    await Future<void>.delayed(Duration.zero);

    expect(cache.entries, isEmpty);

    await notifier.speak(card);
    tts.controller.add(
      const TtsPlaybackEvent.wordBoundary(
        TtsWordRange(text: 'boarding pass', start: 0, end: 8),
      ),
    );
    tts.controller.add(const TtsPlaybackEvent.error());
    await Future<void>.delayed(Duration.zero);
    expect(cache.entries, isEmpty);
  });

  test('cache hit lần lượt highlight pronunciation segments', () async {
    final tts = _FakeTtsService();
    final cache = _FakeCache()..entries['1:0:8:voice|en-US:0.5'] = 24;
    final container = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(tts),
        ttsWordTimingCacheRepositoryProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(() async {
      await tts.controller.close();
      container.dispose();
    });

    await container.read(ttsHighlightControllerProvider.notifier).speak(card);
    tts.controller.add(
      const TtsPlaybackEvent.wordBoundary(
        TtsWordRange(text: 'boarding pass', start: 0, end: 8),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(ttsHighlightControllerProvider).activeSegmentPosition,
      0,
    );

    await Future<void>.delayed(const Duration(milliseconds: 16));
    expect(
      container.read(ttsHighlightControllerProvider).activeSegmentPosition,
      1,
    );
  });
}
