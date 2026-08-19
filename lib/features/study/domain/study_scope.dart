/// Phạm vi từ vựng của một phiên học — thuần, không phụ thuộc
/// Flutter/Riverpod/Drift.
library;

/// Loại phạm vi. Tách enum riêng để `switch` được exhaustive ở data layer.
enum StudyScopeKind {
  /// Toàn bộ bộ học (hành vi mặc định, giống trước khi có scope).
  all,

  /// Chỉ từ thuộc một chủ đề catalog cụ thể (`VocabularyTable.topicId`).
  topic,

  /// Chỉ từ người dùng tự thêm — `topicId IS NULL` (bộ "My Work" của
  /// luồng Reading; xem `docs/tasks/2026-08-04-reading-paste-translate-save.md`).
  manual,
}

/// Giới hạn tập thẻ của một phiên học.
///
/// Value object bất biến, có `==`/`hashCode` ổn định để dùng làm khoá
/// override provider (`studyScopeProvider`) mà không tạo lại phiên học
/// thừa khi rebuild.
class StudyScope {
  const StudyScope._(this.kind, this.topicId);

  /// Học toàn bộ từ đến hạn, không lọc.
  const StudyScope.all() : this._(StudyScopeKind.all, null);

  /// Chỉ học từ đến hạn của chủ đề [topicId].
  const StudyScope.topic(String topicId)
    : this._(StudyScopeKind.topic, topicId);

  /// Chỉ học từ đến hạn do người dùng tự thêm (không thuộc chủ đề nào).
  const StudyScope.manual() : this._(StudyScopeKind.manual, null);

  final StudyScopeKind kind;

  /// Chỉ khác `null` khi [kind] là [StudyScopeKind.topic].
  final String? topicId;

  @override
  bool operator ==(Object other) =>
      other is StudyScope && other.kind == kind && other.topicId == topicId;

  @override
  int get hashCode => Object.hash(kind, topicId);

  @override
  String toString() => topicId == null
      ? 'StudyScope(${kind.name})'
      : 'StudyScope(${kind.name}: $topicId)';
}
