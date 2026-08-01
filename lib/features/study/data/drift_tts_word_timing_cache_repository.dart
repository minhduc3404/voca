import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/tts_word_timing_cache_repository.dart';

class DriftTtsWordTimingCacheRepository
    implements TtsWordTimingCacheRepository {
  DriftTtsWordTimingCacheRepository(this._db);

  final AppDatabase _db;
  Future<void> _writeTail = Future.value();

  @override
  Future<int?> getDurationMs({
    required int vocabId,
    required int wordStartOffset,
    required int wordEndOffset,
    required String voiceKey,
    required double speechRate,
  }) async {
    final row =
        await (_db.select(_db.ttsWordTimingCacheTable)..where(
              (table) =>
                  table.vocabId.equals(vocabId) &
                  table.wordStartOffset.equals(wordStartOffset) &
                  table.wordEndOffset.equals(wordEndOffset) &
                  table.voiceKey.equals(voiceKey) &
                  table.speechRate.equals(speechRate),
            ))
            .getSingleOrNull();
    return row?.durationMs;
  }

  @override
  Future<void> save(TtsWordTimingCacheEntry entry) {
    // Controller có thể ghi fire-and-forget khi các callback đến sát nhau.
    // Nối các lần ghi để select + insert/update không tranh chấp unique key.
    final write = _writeTail.then((_) => _saveAtomically(entry));
    _writeTail = write.then<void>((_) {}, onError: (_, _) {});
    return write;
  }

  Future<void> _saveAtomically(TtsWordTimingCacheEntry entry) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.ttsWordTimingCacheTable)..where(
                (table) =>
                    table.vocabId.equals(entry.vocabId) &
                    table.wordStartOffset.equals(entry.wordStartOffset) &
                    table.wordEndOffset.equals(entry.wordEndOffset) &
                    table.voiceKey.equals(entry.voiceKey) &
                    table.speechRate.equals(entry.speechRate),
              ))
              .getSingleOrNull();
      final now = DateTime.now();
      if (existing == null) {
        await _db
            .into(_db.ttsWordTimingCacheTable)
            .insert(
              TtsWordTimingCacheTableCompanion.insert(
                vocabId: entry.vocabId,
                wordStartOffset: entry.wordStartOffset,
                wordEndOffset: entry.wordEndOffset,
                voiceKey: entry.voiceKey,
                speechRate: entry.speechRate,
                durationMs: entry.durationMs,
                updatedAt: now,
              ),
            );
        return;
      }
      await (_db.update(
        _db.ttsWordTimingCacheTable,
      )..where((table) => table.id.equals(existing.id))).write(
        TtsWordTimingCacheTableCompanion(
          durationMs: Value(entry.durationMs),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
