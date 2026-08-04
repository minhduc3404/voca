import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/conversation/data/mock_script_repository.dart';
import 'package:voca_app/features/conversation/domain/conversation_script.dart';

void main() {
  group('ConversationScript model', () {
    test('parse JSON đầy đủ (mock Ordering Coffee)', () async {
      final repo = MockScriptRepository();
      final scripts = await repo.fetchScripts();

      expect(scripts, hasLength(1));
      final script = scripts.first;

      expect(script.schemaVersion, 1);
      expect(script.id, 'coffee-order-beginner');
      expect(script.title, 'Ordering Coffee');
      expect(script.titleVi, 'Gọi cà phê');
      expect(script.difficulty, 'beginner');
      expect(script.estimatedMinutes, 3);

      expect(script.appRole.name, 'Barista');
      expect(script.userRole.nameVi, 'Khách hàng');

      // targetVocab
      expect(script.targetVocab, hasLength(4));
      expect(script.targetVocab.first.term, 'latte');
      expect(script.targetVocab.first.senseVi, 'cà phê sữa');

      // turns
      expect(script.turns, hasLength(7));
      expect(script.turns.first.id, 't1');
      expect(script.turns.first.isAppTurn, isTrue);

      final userTurn = script.turns[1];
      expect(userTurn.isAppTurn, isFalse);
      expect(userTurn.text, "I'd like a latte, please.");
      expect(userTurn.textVi, 'Cho tôi một ly latte.');
    });

    test('vocabForTurn: match targetVocab xuất hiện trong turn.text', () async {
      final repo = MockScriptRepository();
      final script = (await repo.fetchScripts()).first;

      final t2 = script.turns.firstWhere((t) => t.id == 't2');
      expect(script.vocabForTurn(t2).map((v) => v.term), ['latte']);

      final t5 = script.turns.firstWhere((t) => t.id == 't5');
      // "Great. For here or takeaway?" — chứa cả "for here" lẫn "takeaway".
      expect(
        script.vocabForTurn(t5).map((v) => v.term),
        containsAll(['takeaway', 'for here']),
      );

      final t1 = script.turns.firstWhere((t) => t.id == 't1');
      expect(script.vocabForTurn(t1), isEmpty);
    });

    test('fromJsonString không có trường optional (description/tags) vẫn parse', () {
      const json = '''
      {
        "schemaVersion": 1,
        "id": "min",
        "title": "Min",
        "titleVi": "Tối giản",
        "difficulty": "beginner",
        "estimatedMinutes": 1,
        "roles": {
          "app": { "name": "A", "nameVi": "A" },
          "user": { "name": "U", "nameVi": "U" }
        },
        "targetVocab": [],
        "turns": [
          { "id": "t1", "speaker": "app", "text": "Hi", "textVi": "Chào" }
        ]
      }
      ''';
      final script = ConversationScript.fromJsonString(json);
      expect(script.description, '');
      expect(script.tags, isEmpty);
      expect(script.turns.single.isAppTurn, isTrue);
    });
  });
}
