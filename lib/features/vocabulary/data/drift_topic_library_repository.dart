import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
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

    for (final word in words) {
      final existing = await (_db.select(
        _db.vocabularyTable,
      )..where((t) => t.catalogId.equals(word.id))).getSingleOrNull();

      if (existing == null) {
        await _db
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
              ),
            );
      } else {
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
          ),
        );
      }
    }

    await _db
        .into(_db.downloadedTopicsTable)
        .insertOnConflictUpdate(
          DownloadedTopicsTableCompanion.insert(
            topicId: topic.id,
            downloadedVersion: topic.version,
            downloadedAt: now,
          ),
        );
  }
}
