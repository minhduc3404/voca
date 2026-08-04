import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/conversation_script.dart';

/// State thuần của script player — presentation chỉ render theo state này.
/// Model "focus theo index": không còn turn ẩn/hiện tuần tự hay chọn câu —
/// toàn bộ transcript hiển thị, `focusedIndex` là câu đang phát/highlight.
class ScriptPlayState {
  const ScriptPlayState({required this.script, required this.focusedIndex});

  /// `null` = chưa nạp script (màn vừa mở).
  final ConversationScript? script;
  final int focusedIndex;

  static const empty = ScriptPlayState(script: null, focusedIndex: 0);

  /// Turn đang focus — `null` khi chưa có script.
  ConversationTurn? get focusedTurn {
    final script = this.script;
    if (script == null) return null;
    if (focusedIndex < 0 || focusedIndex >= script.turns.length) return null;
    return script.turns[focusedIndex];
  }

  bool get isFirst => focusedIndex <= 0;

  bool get isLast => script != null && focusedIndex >= script!.turns.length - 1;
}

/// State machine "focus" của script player — orchestration thuần.
/// Screen gọi [start] để nạp script, [focusTurn]/[next]/[previous] để đổi
/// câu đang focus (freehand chạm câu hoặc nút Next/Previous).
class ScriptPlayerController extends Notifier<ScriptPlayState> {
  @override
  ScriptPlayState build() => ScriptPlayState.empty;

  /// Nạp script để chơi — reset về câu đầu.
  void start(ConversationScript script) {
    state = ScriptPlayState(script: script, focusedIndex: 0);
  }

  /// Chuyển focus tới turn ở [index] bất kỳ (chạm câu trong transcript).
  void focusTurn(int index) {
    final script = state.script;
    if (script == null) return;
    if (index < 0 || index >= script.turns.length) return;
    state = ScriptPlayState(script: script, focusedIndex: index);
  }

  /// Focus sang câu kế tiếp — no-op nếu đang ở câu cuối.
  void next() {
    final current = state;
    final script = current.script;
    if (script == null) return;
    final nextIndex = current.focusedIndex + 1;
    if (nextIndex >= script.turns.length) return;
    state = ScriptPlayState(script: script, focusedIndex: nextIndex);
  }

  /// Focus sang câu trước — no-op nếu đang ở câu đầu.
  void previous() {
    final current = state;
    final script = current.script;
    if (script == null) return;
    final prevIndex = current.focusedIndex - 1;
    if (prevIndex < 0) return;
    state = ScriptPlayState(script: script, focusedIndex: prevIndex);
  }

  /// Reset về script rỗng — khi thoát màn play.
  void reset() => state = ScriptPlayState.empty;
}
