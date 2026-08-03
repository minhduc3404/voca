/// Tổng hợp số liệu "Hôm nay" — thuần, không phụ thuộc Flutter/Riverpod/Drift.
library;

/// Số liệu tổng hợp cho màn "Hôm nay", tính từ `ProgressTable`/`VocabularyTable`.
class TodayStudyStats {
  const TodayStudyStats({
    required this.dueCount,
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
    required this.totalCount,
    required this.weakCount,
  });

  /// Thẻ đến hạn hôm nay: `progress == null || nextReview <= now`.
  final int dueCount;

  /// Từ mới chưa từng ôn: progress row có `lastReview == null` hoặc chưa có row.
  final int newCount;

  /// Đang học learning phase (ADR-011): `learningStep != null`.
  final int learningCount;

  /// Đã thuộc review phase: `learningStep == null && reps > 0`.
  final int masteredCount;

  /// Tổng số từ trong bộ học.
  final int totalCount;

  /// Từ yếu cần luyện: `lapses >= 2`.
  final int weakCount;

  @override
  bool operator ==(Object other) =>
      other is TodayStudyStats &&
      other.dueCount == dueCount &&
      other.newCount == newCount &&
      other.learningCount == learningCount &&
      other.masteredCount == masteredCount &&
      other.totalCount == totalCount &&
      other.weakCount == weakCount;

  @override
  int get hashCode =>
      Object.hash(dueCount, newCount, learningCount, masteredCount, totalCount, weakCount);

  @override
  String toString() =>
      'TodayStudyStats(due: $dueCount, new: $newCount, learning: $learningCount, '
      'mastered: $masteredCount, total: $totalCount, weak: $weakCount)';
}

/// Chuỗi ngày học liên tiếp.
class StudyStreak {
  const StudyStreak({required this.current, required this.lastStudyDate});

  /// Số ngày liên tiếp có ≥1 lượt ôn, tính theo quy tắc NGHIÊM: chỉ tính các
  /// ngày đã ôn, không đặc biệt hóa "hôm nay" hay "hôm qua" (không ân hạn).
  final int current;

  /// Ngày gần nhất có học (key `'YYYY-MM-DD'`), `null` nếu chưa từng học.
  final String? lastStudyDate;

  @override
  bool operator ==(Object other) =>
      other is StudyStreak &&
      other.current == current &&
      other.lastStudyDate == lastStudyDate;

  @override
  int get hashCode => Object.hash(current, lastStudyDate);

  @override
  String toString() => 'StudyStreak(current: $current, last: $lastStudyDate)';
}

/// Tính chuỗi ngày học liên tiếp từ tập các ngày đã học.
///
/// Quy tắc NGHIÊM (đã duyệt 2026-08-03): streak = số ngày liên tiếp kết thúc
/// ở ngày gần nhất có học trong [studiedDates]. Không có khái niệm ân hạn —
/// nếu hôm nay chưa học thì streak vẫn tính tới ngày gần nhất đã học; chỉ
/// khi BỎ qua một ngày hoàn toàn (không có log) thì chuỗi mới tụt.
///
/// Hàm thuần: không gọi `DateTime.now()`, [today] truyền vào từ ngoài.
///
/// Date key là `'YYYY-MM-DD'` theo giờ local. So sánh bằng cộng/trừ ngày trên
/// chuỗi (không dùng `DateTime.parse` vì không muốn phụ thuộc timezone ở domain).
int computeStreak(Set<String> studiedDates, {required String today}) {
  if (studiedDates.isEmpty) return 0;

  // Ngày gần nhất có học — không đặc biệt hóa hôm nay. Nếu hôm nay chưa học
  // mà hôm qua có học, streak vẫn còn nguyên (ngày gần nhất = hôm qua).
  var cursor = studiedDates.reduce((a, b) => a.compareTo(b) > 0 ? a : b);

  // Nếu ngày gần nhất cách xa hôm nay > 1 ngày → chuỗi đã đứt từ lâu (vd
  // hôm nay = 2026-08-03, ngày gần nhất = 2026-07-20). Chỉ tính khi cursor
  // là hôm nay hoặc hôm qua, ngược lại không có chuỗi liên tiếp kết thúc
  // gần đây → 0.
  final todayDate = _parseDateKey(today);
  if (todayDate == null) return 0;
  final cursorDate = _parseDateKey(cursor);
  if (cursorDate == null) return 0;
  final daysBetween = todayDate.difference(cursorDate).inDays;
  if (daysBetween < 0 || daysBetween > 1) return 0;

  var count = 0;
  while (studiedDates.contains(cursor)) {
    count++;
    cursor = _previousDay(cursor);
  }
  return count;
}

DateTime? _parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

/// Ngày trước của `'YYYY-MM-DD'` — dùng `DateTime` local (không timezone) rồi
/// format lại, tránh lỗi lịch (tháng 1, năm nhuận...).
String _previousDay(String key) {
  final date = _parseDateKey(key)!;
  final prev = DateTime(date.year, date.month, date.day - 1);
  final mm = prev.month.toString().padLeft(2, '0');
  final dd = prev.day.toString().padLeft(2, '0');
  return '${prev.year}-$mm-$dd';
}

/// Format `DateTime` → key `'YYYY-MM-DD'` theo giờ local.
String dateKey(DateTime date) {
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '${date.year}-$mm-$dd';
}
