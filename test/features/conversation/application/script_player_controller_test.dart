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

  test('start: nạp script, focus câu đầu (turn app)', () {
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.script, isNotNull);
    expect(state.focusedIndex, 0);
    expect(state.focusedTurn!.isAppTurn, isTrue);
    expect(state.isFirst, isTrue);
    expect(state.isLast, isFalse);
  });

  test('next: tăng focusedIndex, dừng ở câu cuối', () {
    controller.next();
    var state = container.read(scriptPlayerControllerProvider);
    expect(state.focusedIndex, 1);
    expect(state.focusedTurn!.isAppTurn, isFalse);

    for (var i = 0; i < 10; i++) {
      controller.next();
    }
    state = container.read(scriptPlayerControllerProvider);
    expect(state.isLast, isTrue);
    expect(state.focusedIndex, state.script!.turns.length - 1);
  });

  test('previous: giảm focusedIndex, dừng ở câu đầu', () {
    controller.next();
    controller.next();
    controller.previous();
    var state = container.read(scriptPlayerControllerProvider);
    expect(state.focusedIndex, 1);

    for (var i = 0; i < 10; i++) {
      controller.previous();
    }
    state = container.read(scriptPlayerControllerProvider);
    expect(state.isFirst, isTrue);
    expect(state.focusedIndex, 0);
  });

  test('focusTurn: nhảy tự do tới index bất kỳ (chạm câu trong transcript)', () {
    controller.focusTurn(4);
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.focusedIndex, 4);
  });

  test('focusTurn: bỏ qua index ngoài phạm vi', () {
    controller.focusTurn(-1);
    var state = container.read(scriptPlayerControllerProvider);
    expect(state.focusedIndex, 0);

    final lastIndex = state.script!.turns.length;
    controller.focusTurn(lastIndex + 5);
    state = container.read(scriptPlayerControllerProvider);
    expect(state.focusedIndex, 0);
  });

  test('reset: về state rỗng', () {
    controller.next();
    controller.reset();
    final state = container.read(scriptPlayerControllerProvider);
    expect(state.script, isNull);
    expect(state.focusedTurn, isNull);
  });

  test('next/previous/focusTurn khi chưa nạp script: no-op', () {
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    final freshController = fresh.read(scriptPlayerControllerProvider.notifier);
    expect(() => freshController.next(), returnsNormally);
    expect(() => freshController.previous(), returnsNormally);
    expect(() => freshController.focusTurn(0), returnsNormally);
    expect(fresh.read(scriptPlayerControllerProvider).script, isNull);
  });
}
