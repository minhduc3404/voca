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
    // Join vocabulary_table với downloaded_topics_table để lấy tên hiển thị.
    // KHÔNG lọc `topic_id IS NOT NULL`: các từ người dùng tự thêm (topic_id
    // NULL) gộp thành đúng một nhóm (SQLite coi các NULL là bằng nhau khi
    // GROUP BY) và trả về với `topicId == null` → `ActiveTopic.isManual`.
    // Trước đây nhóm này bị loại nên tổng số từ liệt kê ở màn Tiến độ không
    // khớp `totalCount`/`dueCount` (vốn luôn đếm cả từ tự thêm).
    final rows = await _db.customSelect(
      '''
      SELECT v.topic_id AS topic_id,
             COALESCE(d.topic_name, v.topic_id) AS name,
             COUNT(*) AS word_count
      FROM vocabulary_table v
      LEFT JOIN downloaded_topics_table d ON d.topic_id = v.topic_id
      GROUP BY v.topic_id
      ORDER BY word_count DESC
      ''',
    ).get();

    return [
      for (final row in rows)
        ActiveTopic(
          topicId: row.readNullable<String>('topic_id'),
          // NULL với nhóm tự thêm — nhãn hiển thị do presentation đặt.
          name: row.readNullable<String>('name') ?? '',
          wordCount: row.read<int>('word_count'),
        ),
    ];
  }
}
