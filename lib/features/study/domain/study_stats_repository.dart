import 'study_scope.dart';
import 'study_stats.dart';

/// Đọc số liệu tổng hợp cho màn "Hôm nay" + danh sách chủ đề đang học.
/// Implementation ở `data/`.
abstract class StudyStatsRepository {
  /// Số liệu tổng hợp tại thời điểm [now].
  Future<TodayStudyStats> getTodayStats(DateTime now);

  /// Danh sách nhóm từ đang học, kèm số từ mỗi nhóm, sắp theo số từ giảm
  /// dần. Gồm các chủ đề catalog đã tải VÀ nhóm từ người dùng tự thêm
  /// (`topicId IS NULL`, xem [ActiveTopic.isManual]) — trước đây nhóm tự
  /// thêm bị loại khỏi danh sách nên không khớp với `dueCount`/`totalCount`
  /// của [getTodayStats] (vốn luôn đếm cả từ tự thêm).
  Future<List<ActiveTopic>> getActiveTopics();
}

/// 1 nhóm từ đang học trên màn "Tiến độ học".
class ActiveTopic {
  const ActiveTopic({
    required this.topicId,
    required this.name,
    required this.wordCount,
  });

  /// `null` = nhóm từ người dùng tự thêm (không thuộc chủ đề catalog nào).
  final String? topicId;

  /// Tên hiển thị (từ `DownloadedTopicsTable.topicName`), fallback [topicId].
  /// Rỗng khi [isManual] — nhãn của nhóm tự thêm do presentation quyết định
  /// (domain không giữ chuỗi UI).
  final String name;

  final int wordCount;

  /// `true` khi đây là nhóm từ tự thêm, không phải chủ đề catalog.
  bool get isManual => topicId == null;

  /// Phạm vi phiên học tương ứng — dùng để mở `MemoScreen` ôn riêng nhóm này.
  StudyScope get scope {
    final id = topicId;
    return id == null ? const StudyScope.manual() : StudyScope.topic(id);
  }

  @override
  bool operator ==(Object other) =>
      other is ActiveTopic &&
      other.topicId == topicId &&
      other.name == name &&
      other.wordCount == wordCount;

  @override
  int get hashCode => Object.hash(topicId, name, wordCount);
}
