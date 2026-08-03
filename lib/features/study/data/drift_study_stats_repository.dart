import '../../../core/db/app_database.dart';
import '../domain/study_stats.dart';
import '../domain/study_stats_repository.dart';

/// Implementation thật của [StudyStatsRepository] — đọc `VocabularyTable` +
/// `ProgressTable` + `DownloadedTopicsTable` để tổng hợp số liệu "Hôm nay".
class DriftStudyStatsRepository implements StudyStatsRepository {
  DriftStudyStatsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<TodayStudyStats> getTodayStats(DateTime now) async {
    final allVocab = await _db.select(_db.vocabularyTable).get();
    final allProgress = await _db.select(_db.progressTable).get();

    var due = 0;
    var newWords = 0;
    var learning = 0;
    var mastered = 0;
    var weak = 0;

    // Map progress theo vocabId — mỗi vocab có tối đa 1 progress (uniqueKey).
    final progressByVocab = {for (final p in allProgress) p.vocabId: p};

    for (final vocab in allVocab) {
      final progress = progressByVocab[vocab.id];
      final isDue = progress == null || !now.isBefore(progress.nextReview);
      if (isDue) due++;
      if (progress == null || progress.lastReview == null) {
        newWords++;
      }
      if (progress?.learningStep != null) learning++;
      if (progress?.learningStep == null && (progress?.reps ?? 0) > 0) {
        mastered++;
      }
      if ((progress?.lapses ?? 0) >= 2) weak++;
    }

    return TodayStudyStats(
      dueCount: due,
      newCount: newWords,
      learningCount: learning,
      masteredCount: mastered,
      totalCount: allVocab.length,
      weakCount: weak,
    );
  }

  @override
  Future<List<ActiveTopic>> getActiveTopics() async {
    // Join vocabulary_table (có topic_id) với downloaded_topics_table để lấy
    // tên hiển thị. Chỉ tính topic có ≥1 từ.
    final rows = await _db.customSelect(
      '''
      SELECT v.topic_id AS topic_id,
             COALESCE(d.topic_name, v.topic_id) AS name,
             COUNT(*) AS word_count
      FROM vocabulary_table v
      LEFT JOIN downloaded_topics_table d ON d.topic_id = v.topic_id
      WHERE v.topic_id IS NOT NULL
      GROUP BY v.topic_id
      ORDER BY word_count DESC
      ''',
    ).get();

    return [
      for (final row in rows)
        ActiveTopic(
          topicId: row.read<String>('topic_id'),
          name: row.read<String>('name'),
          wordCount: row.read<int>('word_count'),
        ),
    ];
  }
}
