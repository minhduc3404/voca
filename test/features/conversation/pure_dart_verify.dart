// Verify nhanh logic thuần (model + state machine) bằng dart run —
// KHÔNG dùng flutter_test (môi trường hiện tại thiếu engine arm64).
// Chỉ import code thuần Dart, không kéo Flutter.
import 'dart:io';

import 'package:voca_app/features/conversation/data/mock_script_repository.dart';
import 'package:voca_app/features/conversation/domain/conversation_script.dart';

// Bản sao tối giản state machine — kiểm tra logic focus/next/previous.
// (Bản thật trong application/ dùng Riverpod Notifier; logic giống hệt.)
class PureState {
  PureState({this.script, this.focusedIndex = 0});

  final ConversationScript? script;
  final int focusedIndex;

  bool get isFirst => focusedIndex <= 0;
  bool get isLast => script != null && focusedIndex >= script!.turns.length - 1;

  PureState start(ConversationScript s) => PureState(script: s, focusedIndex: 0);

  PureState next() {
    final s = script;
    if (s == null) return this;
    final i = focusedIndex + 1;
    if (i >= s.turns.length) return this;
    return PureState(script: s, focusedIndex: i);
  }

  PureState previous() {
    final s = script;
    if (s == null) return this;
    final i = focusedIndex - 1;
    if (i < 0) return this;
    return PureState(script: s, focusedIndex: i);
  }

  PureState focusTurn(int index) {
    final s = script;
    if (s == null) return this;
    if (index < 0 || index >= s.turns.length) return this;
    return PureState(script: s, focusedIndex: index);
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
  check('turn 2 là user', !script.turns[1].isAppTurn);
  check('turn 2 text = latte order', script.turns[1].text == "I'd like a latte, please.");
  check('targetVocab 4 từ', script.targetVocab.length == 4);

  // vocabForTurn
  final t2Vocab = script.vocabForTurn(script.turns[1]).map((v) => v.term).toList();
  check('vocabForTurn t2 == [latte]', t2Vocab.length == 1 && t2Vocab.first == 'latte');
  final t5 = script.turns.firstWhere((t) => t.id == 't5');
  final t5Vocab = script.vocabForTurn(t5).map((v) => v.term).toSet();
  check(
    'vocabForTurn t5 chứa takeaway + for here',
    t5Vocab.containsAll({'takeaway', 'for here'}),
  );
  final t1Vocab = script.vocabForTurn(script.turns[0]);
  check('vocabForTurn t1 rỗng', t1Vocab.isEmpty);

  // State machine
  var s = PureState().start(script);
  check('start: focus 0, turn app, isFirst', s.focusedIndex == 0 && s.script!.turns[0].isAppTurn && s.isFirst);
  check('chưa isLast', !s.isLast);

  s = s.next(); // t2
  check('next → focus 1 (user)', s.focusedIndex == 1 && !s.script!.turns[1].isAppTurn);

  s = s.previous();
  check('previous → focus 0', s.focusedIndex == 0);

  s = s.focusTurn(4); // t5
  check('focusTurn(4) → focus 4', s.focusedIndex == 4);

  s = s.focusTurn(-1); // out of range, no-op
  check('focusTurn(-1) no-op → vẫn focus 4', s.focusedIndex == 4);

  // đi tới cuối
  var atEnd = PureState().start(script);
  for (var i = 0; i < script.turns.length + 3; i++) {
    atEnd = atEnd.next();
  }
  check('next lặp lại → dừng ở isLast', atEnd.isLast && atEnd.focusedIndex == script.turns.length - 1);

  // đi ngược về đầu
  var atStart = atEnd;
  for (var i = 0; i < script.turns.length + 3; i++) {
    atStart = atStart.previous();
  }
  check('previous lặp lại → dừng ở isFirst', atStart.isFirst && atStart.focusedIndex == 0);

  stdout.writeln(failures == 0 ? '\nALL PASS' : '\n$failures FAILURES');
  exit(failures == 0 ? 0 : 1);
}
