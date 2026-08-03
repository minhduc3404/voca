import 'study_stats.dart';

/// Đọc số liệu tổng hợp cho màn "Hôm nay" + danh sách chủ đề đang học.
/// Implementation ở `data/`.
abstract class StudyStatsRepository {
  /// Số liệu tổng hợp tại thời điểm [now].
  Future<TodayStudyStats> getTodayStats(DateTime now);

  /// Danh sách chủ đề đang học (topic đã tải + có ≥1 từ còn đang học),
  /// kèm số từ mỗi chủ đề. Sắp theo số từ giảm dần.
  Future<List<ActiveTopic>> getActiveTopics();
}

/// 1 chủ đề đang học trên màn "Hôm nay".
class ActiveTopic {
  const ActiveTopic({required this.topicId, required this.name, required this.wordCount});

  final String topicId;

  /// Tên hiển thị (từ `DownloadedTopicsTable.topicName`), fallback [topicId].
  final String name;

  final int wordCount;

  @override
  bool operator ==(Object other) =>
      other is ActiveTopic &&
      other.topicId == topicId &&
      other.name == name &&
      other.wordCount == wordCount;

  @override
  int get hashCode => Object.hash(topicId, name, wordCount);
}
