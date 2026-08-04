import '../domain/conversation_script.dart';
import '../domain/script_repository.dart';

/// MVP: trả script hardcode (kịch bản "Ordering Coffee" — xem
/// `docs/analysis/conversation-script-draft.md` §3).
///
/// Tương lai: thay bằng repository tải JSON từ Firebase Storage — parse
/// cùng model, UI/application không đổi.
class MockScriptRepository implements ScriptRepository {
  @override
  Future<List<ConversationScript>> fetchScripts() async {
    return [ConversationScript.fromJsonString(_orderingCoffee)];
  }
}

const String _orderingCoffee = '''
{
  "schemaVersion": 1,
  "id": "coffee-order-beginner",
  "title": "Ordering Coffee",
  "titleVi": "Gọi cà phê",
  "description": "A simple order at a coffee shop counter.",
  "descriptionVi": "Gọi đồ uống đơn giản tại quầy cà phê.",
  "difficulty": "beginner",
  "tags": ["daily-life", "food-drink"],
  "estimatedMinutes": 3,
  "roles": {
    "app": { "name": "Barista", "nameVi": "Nhân viên quầy" },
    "user": { "name": "Customer", "nameVi": "Khách hàng" }
  },
  "targetVocab": [
    { "term": "latte", "senseVi": "cà phê sữa" },
    { "term": "iced", "senseVi": "có đá" },
    { "term": "takeaway", "senseVi": "mang đi" },
    { "term": "for here", "senseVi": "dùng tại chỗ" }
  ],
  "turns": [
    {
      "id": "t1",
      "speaker": "app",
      "text": "Hi! Welcome to Café Voca. What can I get for you today?",
      "textVi": "Xin chào! Chào mừng đến Café Voca. Hôm nay anh/chị dùng gì ạ?"
    },
    {
      "id": "t2",
      "speaker": "user",
      "text": "I'd like a latte, please.",
      "textVi": "Cho tôi một ly latte.",
      "choices": [
        { "text": "I'd like a latte, please.", "textVi": "Cho tôi một ly latte.", "targetWords": ["latte"] },
        { "text": "Can I have a latte, please?", "textVi": "Cho tôi một ly latte được không?", "targetWords": ["latte"] },
        { "text": "A latte, please.", "textVi": "Một ly latte.", "targetWords": ["latte"] }
      ]
    },
    {
      "id": "t3",
      "speaker": "app",
      "text": "Sure! Hot or iced?",
      "textVi": "Vâng! Uống nóng hay đá?"
    },
    {
      "id": "t4",
      "speaker": "user",
      "text": "Iced, please.",
      "textVi": "Đá ạ.",
      "choices": [
        { "text": "Iced, please.", "textVi": "Đá ạ.", "targetWords": ["iced"] },
        { "text": "I'll have it iced.", "textVi": "Cho tôi loại đá.", "targetWords": ["iced"] }
      ]
    },
    {
      "id": "t5",
      "speaker": "app",
      "text": "Great. For here or takeaway?",
      "textVi": "Tuyệt. Dùng tại chỗ hay mang đi?"
    },
    {
      "id": "t6",
      "speaker": "user",
      "text": "Takeaway, please.",
      "textVi": "Mang đi ạ.",
      "choices": [
        { "text": "Takeaway, please.", "textVi": "Mang đi ạ.", "targetWords": ["takeaway"] },
        { "text": "To go, please.", "textVi": "Mang đi ạ.", "targetWords": ["takeaway"] }
      ]
    },
    {
      "id": "t7",
      "speaker": "app",
      "text": "One iced latte to go. That'll be ready in a minute. See you soon!",
      "textVi": "Một ly latte đá mang đi. Chờ một phút nhé. Hẹn gặp lại!"
    }
  ]
}
''';
