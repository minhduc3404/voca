// Verify nhanh logic thuần (model + state machine) bằng dart run —
// KHÔNG dùng flutter_test (môi trường hiện tại thiếu engine arm64).
// Chỉ import code thuần Dart, không kéo Flutter.
import 'dart:io';

import 'package:voca_app/features/conversation/data/mock_script_repository.dart';
import 'package:voca_app/features/conversation/domain/conversation_script.dart';

// Bản sao tối giản state machine — kiểm tra logic advance/start/complete.
// (Bản thật trong application/ dùng Riverpod Notifier; logic giống hệt.)
class PureState {
  PureState({this.script, this.index = 0, this.used = const {}});

  final ConversationScript? script;
  final int index;
  final Set<String> used;

  bool get completed => script != null && index >= script!.turns.length;

  PureState start(ConversationScript s) =>
      PureState(script: s, index: 0, used: {});

  PureState advance([ScriptChoice? choice]) {
    if (script == null || completed) return this;
    final turn = script!.turns[index];
    final nextUsed = {...used};
    if (choice != null && !turn.isAppTurn) {
      nextUsed.addAll(choice.targetWords);
    }
    return PureState(script: script, index: index + 1, used: nextUsed);
  }
}

int failures = 0;

void check(String label, bool cond) {
  if (cond) {
    stdout.writeln('  ok  $label');
  } else {
    failures++;
    stdout.writeln('FAIL  $label');
  }
}

Future<void> main() async {
  final scripts = await MockScriptRepository().fetchScripts();
  final script = scripts.single;

  // Model
  check('schemaVersion == 1', script.schemaVersion == 1);
  check('id == coffee-order-beginner', script.id == 'coffee-order-beginner');
  check('7 turns', script.turns.length == 7);
  check('turn 1 là app', script.turns[0].isAppTurn);
  check('turn 2 là user + 3 choices', !script.turns[1].isAppTurn && script.turns[1].choices.length == 3);
  check('choice đầu targetWords=[latte]', script.turns[1].choices.first.targetWords.first == 'latte');
  check('targetVocab 4 từ', script.targetVocab.length == 4);

  // State machine
  var s = PureState().start(script);
  check('start: index 0, turn app', s.index == 0 && s.script!.turns[0].isAppTurn);
  check('chưa completed', !s.completed);

  s = s.advance(); // t1 app
  check('advance app → index 1 (user)', s.index == 1);

  s = s.advance(script.turns[1].choices.first); // t2 latte
  check('advance user → index 2 + used={latte}', s.index == 2 && s.used.contains('latte'));

  s = s.advance(); // t3 app
  s = s.advance(script.turns[3].choices.first); // t4 iced
  check('used có latte+iced', s.used.containsAll(['latte', 'iced']));

  // chơi hết
  var done = PureState().start(script);
  for (final t in script.turns) {
    if (!t.isAppTurn) {
      done = done.advance(t.choices.first);
    } else {
      done = done.advance();
    }
  }
  check('hết script → completed', done.completed);
  check('used = latte,iced,takeaway', done.used.containsAll(['latte', 'iced', 'takeaway']) && done.used.length == 3);

  stdout.writeln(failures == 0 ? '\nALL PASS' : '\n$failures FAILURES');
  exit(failures == 0 ? 0 : 1);
}
