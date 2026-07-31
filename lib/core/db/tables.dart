import 'package:drift/drift.dart';

/// Định nghĩa Drift table — không chứa business logic (PLAN-PHASE-1-2.md).
///
/// Schema đã duyệt kèm sample-data review (2026-07-30) — xem
/// PLAN-PHASE-1-2.md mục "NEW — core/db/tables.dart".
class VocabularyTable extends Table {
  /// Khóa chính, tự tăng.
  IntColumn get id => integer().autoIncrement()();

  /// Từ tiếng Anh cần học — mặt trước của thẻ.
  TextColumn get term => text()();

  /// Nghĩa tiếng Việt — mặt sau của thẻ.
  TextColumn get definition => text()();

  /// Ngôn ngữ của [term]. Hiện cố định `'en'` — app chỉ học tiếng Anh, UI/
  /// [definition] luôn tiếng Việt. Không tách `termLanguage`/
  /// `definitionLanguage` trừ khi thật sự cần hỗ trợ nhiều cặp ngôn ngữ.
  TextColumn get language => text()();

  /// Phiên âm IPA, vd `/ɪˈfem.ər.əl/` — bắt buộc để người học đọc đúng.
  TextColumn get phonetic => text()();

  /// Từ loại (noun/verb/adj/adv...). Nullable — không phải nguồn dữ liệu
  /// nào cũng xác định được từ loại rõ ràng (vd import tự động từ điển),
  /// UI cần tự xử lý khi thiếu (không hiển thị thay vì hiển thị rỗng).
  TextColumn get partOfSpeech => text().nullable()();

  /// Câu ví dụ có dùng [term] — cho ngữ cảnh, tăng hiệu quả ghi nhớ SRS.
  TextColumn get exampleSentence => text()();

  /// Thời điểm từ được thêm vào — phục vụ audit/sort, không dùng cho SRS.
  DateTimeColumn get createdAt => dateTime()();

  /// ID ổn định của từ trong catalog remote (vd `"travel-001"`), `null`
  /// nếu từ được nhập tay/seed cục bộ, không đến từ catalog. Dùng để
  /// match lại đúng row khi đồng bộ lại một chủ đề đã tải — tránh tạo
  /// trùng, giữ nguyên tiến độ SRS đã có. Thêm ở schema v3.
  TextColumn get catalogId => text().nullable().unique()();
}

class ProgressTable extends Table {
  /// Khóa chính, tự tăng.
  IntColumn get id => integer().autoIncrement()();

  /// FK → `VocabularyTable.id`. Xóa từ vựng sẽ xóa luôn dòng tiến độ này
  /// (`CASCADE`) — không có soft-delete, mất lịch sử ôn tập của từ đó.
  IntColumn get vocabId =>
      integer().references(VocabularyTable, #id, onDelete: KeyAction.cascade)();

  /// Khoảng cách tới lần ôn tiếp theo, đơn vị NGÀY. Xem ADR-010 (SM-2).
  IntColumn get interval => integer()();

  /// Hệ số dễ nhớ SM-2 — khởi tạo 2.5, sàn 1.3 (ADR-010).
  RealColumn get easeFactor => real()();

  /// Số lần trả lời đúng liên tiếp kể từ lần lapse gần nhất. Reset về 0
  /// khi rating = Again.
  IntColumn get reps => integer()();

  /// Tổng số lần trả lời sai (Again) trong suốt lịch sử của từ này —
  /// không reset, chỉ tăng.
  IntColumn get lapses => integer()();

  /// `null` = đã graduate, ở review phase (`interval` tính bằng ngày).
  /// `0, 1, ...` = đang ở learning/relearning phase, index vào
  /// `learningStepsMinutes` (phút) — xem ADR-011. Thêm ở schema v2.
  IntColumn get learningStep => integer().nullable()();

  /// Mốc thời gian thẻ này đến hạn ôn lại tiếp theo.
  DateTimeColumn get nextReview => dateTime()();

  /// Lần ôn gần nhất. `null` nghĩa là thẻ chưa từng được ôn (vẫn ở trạng
  /// thái mới, dù đã có dòng progress).
  DateTimeColumn get lastReview => dateTime().nullable()();

  /// Thời điểm dòng tiến độ này được tạo lần đầu.
  DateTimeColumn get createdAt => dateTime()();

  /// Thời điểm dòng tiến độ này được ghi đè lần gần nhất (mỗi lần
  /// `recordAnswer`).
  DateTimeColumn get updatedAt => dateTime()();

  // Mỗi từ vựng chỉ có đúng 1 dòng tiến độ SRS.
  @override
  List<Set<Column>> get uniqueKeys => [
    {vocabId},
  ];
}

/// Theo dõi chủ đề nào đã tải về máy, ở version nào — để phát hiện chủ
/// đề có bản cập nhật trên catalog remote (Firebase Storage). Thêm ở
/// schema v3.
class DownloadedTopicsTable extends Table {
  /// ID chủ đề, khớp `Topic.id` trong catalog (vd `"travel"`).
  TextColumn get topicId => text()();

  /// Version của chủ đề tại thời điểm tải — so với version hiện tại trên
  /// remote để biết có cần đồng bộ lại không.
  IntColumn get downloadedVersion => integer()();

  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {topicId};
}
