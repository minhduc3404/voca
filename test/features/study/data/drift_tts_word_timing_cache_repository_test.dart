import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/features/study/data/drift_tts_word_timing_cache_repository.dart';
import 'package:voca_app/features/study/domain/tts_word_timing_cache_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTtsWordTimingCacheRepository repository;
  late int vocabId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTtsWordTimingCacheRepository(db);
    vocabId = await db
        .into(db.vocabularyTable)
        .insert(
          VocabularyTableCompanion.insert(
            term: 'boarding pass',
            definition: 'thẻ lên máy bay',
            language: 'en',
            phonetic: '/ˈbɔːr.dɪŋ pæs/',
            exampleSentence: 'Show your boarding pass.',
            createdAt: DateTime(2026, 8, 2),
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'cache phân vùng theo word range, voice và rate; save lại ghi đè',
    () async {
      const base = TtsWordTimingCacheEntry(
        vocabId: 1,
        wordStartOffset: 0,
        wordEndOffset: 8,
        voiceKey: 'voice-a|en-US',
        speechRate: .5,
        durationMs: 610,
      );
      await repository.save(
        TtsWordTimingCacheEntry(
          vocabId: vocabId,
          wordStartOffset: base.wordStartOffset,
          wordEndOffset: base.wordEndOffset,
          voiceKey: base.voiceKey,
          speechRate: base.speechRate,
          durationMs: base.durationMs,
        ),
      );

      expect(
        await repository.getDurationMs(
          vocabId: vocabId,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice-a|en-US',
          speechRate: .5,
        ),
        610,
      );
      expect(
        await repository.getDurationMs(
          vocabId: vocabId,
          wordStartOffset: 9,
          wordEndOffset: 13,
          voiceKey: 'voice-a|en-US',
          speechRate: .5,
        ),
        isNull,
      );
      expect(
        await repository.getDurationMs(
          vocabId: vocabId,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice-b|en-US',
          speechRate: .5,
        ),
        isNull,
      );

      await repository.save(
        TtsWordTimingCacheEntry(
          vocabId: vocabId,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice-a|en-US',
          speechRate: .5,
          durationMs: 590,
        ),
      );
      expect(
        await repository.getDurationMs(
          vocabId: vocabId,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice-a|en-US',
          speechRate: .5,
        ),
        590,
      );

      await Future.wait([
        repository.save(
          TtsWordTimingCacheEntry(
            vocabId: vocabId,
            wordStartOffset: 0,
            wordEndOffset: 8,
            voiceKey: 'voice-a|en-US',
            speechRate: .5,
            durationMs: 580,
          ),
        ),
        repository.save(
          TtsWordTimingCacheEntry(
            vocabId: vocabId,
            wordStartOffset: 0,
            wordEndOffset: 8,
            voiceKey: 'voice-a|en-US',
            speechRate: .5,
            durationMs: 570,
          ),
        ),
      ]);
      expect(
        await repository.getDurationMs(
          vocabId: vocabId,
          wordStartOffset: 0,
          wordEndOffset: 8,
          voiceKey: 'voice-a|en-US',
          speechRate: .5,
        ),
        570,
      );
    },
  );
}
