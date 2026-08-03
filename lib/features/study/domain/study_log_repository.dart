/// Repository ghi nhật ký ôn tập theo ngày — nguồn dữ liệu cho streak.
library;

/// Lưu/đọc các ngày đã học (≥1 lượt trả lời). Implementation ở `data/`.
abstract class StudyLogRepository {
  /// Trả về tập các ngày đã có ≥1 lượt ôn, key `'YYYY-MM-DD'` (giờ local).
  Future<Set<String>> getStudyDates();

  /// Ghi nhận một lượt ôn xảy ra vào [date].
  ///
  /// [isNewWord] = true nếu từ đó ôn lần đầu tiên (trước khi ghi nhận,
  /// progress row có `lastReview == null`) — dùng để tăng `newCount`.
  /// Upsert: nếu ngày đã tồn tại thì tăng `reviewCount` (+1 nếu isNewWord).
  Future<void> recordStudy({required DateTime date, required bool isNewWord});
}
