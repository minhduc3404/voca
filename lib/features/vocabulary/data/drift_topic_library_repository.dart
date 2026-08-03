import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/lexicon/pronunciation_segment.dart';
import '../domain/catalog_word.dart';
import '../domain/downloaded_topic.dart';
import '../domain/topic.dart';
import '../domain/topic_library_repository.dart';

/// Implementation thật của [TopicLibraryRepository] dùng Drift/SQLite —
/// ghi vào `VocabularyTable`/`DownloadedTopicsTable` sẵn có, không phụ
/// thuộc gì tới `study/`.
class DriftTopicLibraryRepository implements TopicLibraryRepository {
  DriftTopicLibraryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<DownloadedTopic>> getDownloadedTopics() async {
    final rows = await _db.select(_db.downloadedTopicsTable).get();
    return rows
        .map(
          (row) => DownloadedTopic(
            topicId: row.topicId,
            downloadedVersion: row.downloadedVersion,
            downloadedAt: row.downloadedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> importTopic(Topic topic, List<CatalogWord> words) async {
    final now = DateTime.now();

    await _db.transaction(() async {
      for (final word in words) {
        final existing = await (_db.select(
          _db.vocabularyTable,
        )..where((t) => t.catalogId.equals(word.id))).getSingleOrNull();

        final vocabId = existing == null
            ? await _db
                  .into(_db.vocabularyTable)
                  .insert(
                    VocabularyTableCompanion.insert(
                      term: word.term,
                      definition: word.definition,
                      language: 'en',
                      phonetic: word.phonetic,
                      partOfSpeech: Value(word.partOfSpeech),
                      exampleSentence: word.exampleSentence,
                      createdAt: now,
                      catalogId: Value(word.id),
                      topicId: Value(topic.id),
                    ),
                  )
            : existing.id;
        if (existing != null) {
          // Chỉ cập nhật nội dung — giữ nguyên `id` để tiến độ SRS (FK qua
          // `ProgressTable.vocabId`) không bị mất khi catalog có bản sửa.
          await (_db.update(
            _db.vocabularyTable,
          )..where((t) => t.catalogId.equals(word.id))).write(
            VocabularyTableCompanion(
              term: Value(word.term),
              definition: Value(word.definition),
              phonetic: Value(word.phonetic),
              partOfSpeech: Value(word.partOfSpeech),
              exampleSentence: Value(word.exampleSentence),
              topicId: Value(topic.id),
            ),
          );
          if (existing.term != word.term) {
            await (_db.delete(
              _db.ttsWordTimingCacheTable,
            )..where((table) => table.vocabId.equals(existing.id))).go();
          }
        }
        await _replaceSegments(vocabId, word.pronunciationSegments);
      }

      await _db
          .into(_db.downloadedTopicsTable)
          .insertOnConflictUpdate(
            DownloadedTopicsTableCompanion.insert(
              topicId: topic.id,
              topicName: Value(topic.name),
              downloadedVersion: topic.version,
              downloadedAt: now,
            ),
          );
    });
  }

  Future<void> _replaceSegments(
    int vocabId,
    List<PronunciationSegment> segments,
  ) async {
    await (_db.delete(
      _db.pronunciationSegmentsTable,
    )..where((table) => table.vocabId.equals(vocabId))).go();
    if (segments.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(_db.pronunciationSegmentsTable, [
        for (final segment in segments)
          PronunciationSegmentsTableCompanion.insert(
            vocabId: vocabId,
            position: segment.position,
            startOffset: segment.start,
            endOffset: segment.end,
            segmentText: segment.text,
            ipa: segment.ipa,
            stress: segment.stress.name,
            timingWeight: segment.timingWeight,
          ),
      ]);
    });
  }
}
