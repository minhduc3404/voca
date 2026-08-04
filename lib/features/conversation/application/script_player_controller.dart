import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/conversation_script.dart';

/// Một turn trong phiên đang chơi.
class ActiveTurn {
  const ActiveTurn({required this.turn, required this.selectedChoice});

  final ConversationTurn turn;

  /// Choice user đã bấm — `null` nếu chưa chọn (turn app không có).
  final ScriptChoice? selectedChoice;

  /// `true` khi đã hiển thị xong và có thể advance.
  bool get isResolved => turn.isAppTurn || selectedChoice != null;
}

/// State thuần của script player — presentation chỉ render theo state này.
class ScriptPlayState {
  const ScriptPlayState({
    required this.script,
    required this.currentIndex,
    required this.usedTargetWords,
  });

  /// `null` = chưa nạp script (màn vừa mở).
  final ConversationScript? script;
  final int currentIndex;

  /// Các từ trong `targetVocab` user đã dùng qua choice — cho summary.
  final Set<String> usedTargetWords;

  static const empty = ScriptPlayState(
    script: null,
    currentIndex: 0,
    usedTargetWords: <String>{},
  );

  /// Turn hiện tại — `null` khi chưa có script hoặc đã hết.
  ActiveTurn? get currentTurn {
    final script = this.script;
    if (script == null) return null;
    if (currentIndex >= script.turns.length) return null;
    return ActiveTurn(turn: script.turns[currentIndex], selectedChoice: null);
  }

  /// `true` khi đã chơi xong tất cả turn.
  bool get isCompleted => script != null && currentIndex >= script!.turns.length;
}

/// State machine turn của script player — orchestration thuần.
/// Screen gọi [start] để nạp script, [advance] sau mỗi turn.
class ScriptPlayerController extends Notifier<ScriptPlayState> {
  @override
  ScriptPlayState build() => ScriptPlayState.empty;

  /// Nạp script để chơi — reset state.
  void start(ConversationScript script) {
    state = ScriptPlayState(
      script: script,
      currentIndex: 0,
      usedTargetWords: <String>{},
    );
  }

  /// Advance sang turn kế — khi app đã nói xong / user đã chọn.
  /// Từ `targetVocab` của choice được bấm sẽ được ghi nhận cho summary.
  void advance([ScriptChoice? selectedChoice]) {
    final current = state;
    final script = current.script;
    if (script == null || current.isCompleted) return;

    final turn = script.turns[current.currentIndex];
    final used = {...current.usedTargetWords};
    if (selectedChoice != null && !turn.isAppTurn) {
      used.addAll(selectedChoice.targetWords);
    }

    state = ScriptPlayState(
      script: script,
      currentIndex: current.currentIndex + 1,
      usedTargetWords: used,
    );
  }

  /// Reset về script rỗng — khi thoát màn play.
  void reset() => state = ScriptPlayState.empty;
}
