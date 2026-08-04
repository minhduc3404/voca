import 'conversation_script.dart';

/// Nguồn cung cấp kịch bản hội thoại.
///
/// MVP: mock (hardcode trong code). Tương lai: tải từ Firebase Storage
/// (download raw JSON, parse cùng model) — UI/application không đổi.
abstract class ScriptRepository {
  /// Danh sách tất cả script có sẵn.
  Future<List<ConversationScript>> fetchScripts();
}
