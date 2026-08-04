import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/conversation/application/providers.dart';
import 'package:voca_app/features/conversation/application/script_player_controller.dart';
import 'package:voca_app/features/conversation/data/mock_script_repository.dart';

void main() {
  late ProviderContainer container;
  late ScriptPlayerController controller;

  setUp(() async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    controller = container.read(
      scriptPlayerControllerProvider.notifier,
    );
    final scripts = await MockScriptRepository().fetchScripts();
    controller.start(scripts.first);
  });

  test('start: nạp script, turn đầu là turn app', () {
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.script, isNotNull);
    expect(state.currentIndex, 0);
    expect(state.currentTurn!.turn.isAppTurn, isTrue);
    expect(state.usedTargetWords, isEmpty);
  });

  test('advance qua turn app (không chọn) — chỉ tăng index', () {
    controller.advance();
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.currentIndex, 1);
    expect(state.currentTurn!.turn.isAppTurn, isFalse);
    expect(state.usedTargetWords, isEmpty);
  });

  test('chọn choice: ghi nhận targetWords + advance', () {
    controller.advance(); // sang turn user đầu (t2)
    final userTurn = container
        .read(scriptPlayerControllerProvider)
        .currentTurn!
        .turn;
    final choice = userTurn.choices.first; // "I'd like a latte" → latte
    controller.advance(choice);

    final state = container.read(scriptPlayerControllerProvider);
    expect(state.currentIndex, 2);
    expect(state.usedTargetWords, {'latte'});
  });

  test('chọn nhiều choice: gộp targetWords', () {
    controller.advance(); // t2
    final first = container
        .read(scriptPlayerControllerProvider)
        .currentTurn!
        .turn
        .choices
        .first;
    controller.advance(first); // latte

    controller.advance(); // t3 (app)
    final second = container
        .read(scriptPlayerControllerProvider)
        .currentTurn!
        .turn
        .choices
        .first;
    controller.advance(second); // iced

    final state = container.read(scriptPlayerControllerProvider);
    expect(state.usedTargetWords, {'latte', 'iced'});
  });

  test('chơi hết script → isCompleted = true', () {
    // t1..t6: advance qua từng turn; t2/t4/t6 có choice.
    for (var i = 0; i < 6; i++) {
      final turn = container
          .read(scriptPlayerControllerProvider)
          .currentTurn!
          .turn;
      controller.advance(turn.choices.isNotEmpty ? turn.choices.first : null);
    }
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.isCompleted, isTrue);
    expect(state.currentTurn, isNull);
    expect(state.usedTargetWords, {'latte', 'iced', 'takeaway'});
  });

  test('advance khi chưa nạp script: no-op', () {
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    final freshController = fresh.read(scriptPlayerControllerProvider.notifier);
    expect(() => freshController.advance(), returnsNormally);
    expect(fresh.read(scriptPlayerControllerProvider).script, isNull);
  });
}
