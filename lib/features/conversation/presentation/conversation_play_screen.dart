import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../application/providers.dart';
import '../application/script_player_controller.dart';
import '../application/tts_turn_highlight_controller.dart';
import '../domain/conversation_script.dart';
import 'conversation_summary_screen.dart';
import 'widgets/primary_button.dart';

/// Script player — hiển thị turn app (TTS + highlight + hint) và turn user
/// (chọn câu gợi ý). State do [ScriptPlayerController] điều phối.
class ConversationPlayScreen extends ConsumerStatefulWidget {
  const ConversationPlayScreen({required this.script, super.key});

  final ConversationScript script;

  @override
  ConsumerState<ConversationPlayScreen> createState() =>
      _ConversationPlayScreenState();
}

class _ConversationPlayScreenState
    extends ConsumerState<ConversationPlayScreen> {
  @override
  void initState() {
    super.initState();
    // Nạp script vào player khi mở màn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(scriptPlayerControllerProvider.notifier).start(widget.script);
    });
  }

  @override
  void dispose() {
    // Dừng highlight + TTS còn đang nói trước khi rời màn.
    ref.read(ttsTurnHighlightControllerProvider.notifier).clear();
    ref.read(scriptPlayerControllerProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(scriptPlayerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.script.titleVi),
        leading: BackButton(onPressed: () => _confirmExit(context)),
      ),
      body: playState.script != null
          ? _buildBody(playState)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBody(ScriptPlayState playState) {
    final active = playState.currentTurn;
    if (playState.isCompleted || active == null) {
      return _SummaryPlaceholder(
        usedTargetWords: playState.usedTargetWords,
        onFinish: () => _goToSummary(playState.usedTargetWords),
      );
    }

    final turn = active.turn;
    final role = turn.isAppTurn
        ? playState.script!.appRole
        : playState.script!.userRole;

    return SafeArea(
      child: Column(
        children: [
          // Role hiện tại.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              role.nameVi,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textFaint,
              ),
            ),
          ),
          // Phần hội thoại — keyed theo turn để state TTS không bị tái sử dụng
          // sai giữa các turn (mỗi turn app tự nói 1 lần từ initState).
          Expanded(
            child: turn.isAppTurn
                ? _AppTurnView(key: ValueKey(turn.id), turn: turn)
                : _UserTurnView(key: ValueKey(turn.id), turn: turn),
          ),
          // Nút advance (ẩn khi turn app đang nói).
          if (active.isResolved)
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: 'Tiếp tục',
                onPressed: () {
                  final notifier = ref.read(
                    scriptPlayerControllerProvider.notifier,
                  );
                  if (turn.isAppTurn) {
                    notifier.advance();
                  } else {
                    notifier.advance(active.selectedChoice);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thoát buổi luyện?'),
        content: const Text('Tiến trình hội thoại sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (shouldExit == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _goToSummary(Set<String> usedTargetWords) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationSummaryScreen(
          script: widget.script,
          usedTargetWords: usedTargetWords,
        ),
      ),
    );
  }
}

/// Turn do app nói — TTS + highlight + hint (nghe lại / xem nghĩa).
/// Stateful + keyed theo turn.id: speak chỉ chạy 1 lần trong initState,
/// không bị re-trigger khi highlight rebuild.
class _AppTurnView extends ConsumerStatefulWidget {
  const _AppTurnView({required this.turn, super.key});

  final ConversationTurn turn;

  @override
  ConsumerState<_AppTurnView> createState() => _AppTurnViewState();
}

class _AppTurnViewState extends ConsumerState<_AppTurnView> {
  @override
  void initState() {
    super.initState();
    // Speak 1 lần khi turn xuất hiện (turn mới = key mới → state mới).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(ttsTurnHighlightControllerProvider.notifier)
          .speak(widget.turn.text);
    });
  }

  @override
  void dispose() {
    // Rời turn app → dừng highlight, tránh highlight cũ hiện ở turn user.
    ref.read(ttsTurnHighlightControllerProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = ref.watch(ttsTurnHighlightControllerProvider);
    final controller = ref.read(ttsTurnHighlightControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _HighlightedText(
            text: widget.turn.text,
            wordStart: highlight.wordStart,
            wordEnd: highlight.wordEnd,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Nghe lại',
                icon: AppIcon('volume-up', size: 22, color: AppColors.controlIcon),
                onPressed: () => controller.speak(widget.turn.text),
              ),
              IconButton(
                tooltip: 'Xem nghĩa',
                icon: AppIcon('book-open', size: 22, color: AppColors.controlIcon),
                onPressed: () => _showTranslation(context, widget.turn),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTranslation(BuildContext context, ConversationTurn turn) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(turn.text),
        content: Text(turn.textVi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

/// Turn do user trả lời — hiện các câu gợi ý để bấm chọn.
class _UserTurnView extends ConsumerWidget {
  const _UserTurnView({required this.turn, super.key});

  final ConversationTurn turn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choices = turn.choices;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Chọn câu trả lời:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: choices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final choice = choices[index];
                return _ChoiceButton(
                  choice: choice,
                  onTap: () {
                    ref
                        .read(scriptPlayerControllerProvider.notifier)
                        .advance(choice);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.choice, required this.onTap});

  final ScriptChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.controlBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(choice.text, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                choice.textVi,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Render text turn app, tô sáng từ đang đọc (word boundary) — có animation
/// scale + màu theo pattern `_TermSpan` của study (word_card.dart):
/// `AnimatedScale` + `AnimatedDefaultTextStyle` (160ms easeOut).
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.wordStart,
    required this.wordEnd,
  });

  final String text;
  final int? wordStart;
  final int? wordEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = textTheme.headlineSmall?.copyWith(height: 1.4);

    if (wordStart == null || wordEnd == null) {
      return Text(text, style: baseStyle);
    }

    // Tách text thành các đoạn theo word boundary; đoạn đang đọc được
    // highlight với animation. Dùng Wrap + widget thay vì Text.rich vì
    // TextSpan không animate được (pattern `_TermSpan` của study).
    final segments = <({String text, bool isActive})>[];
    var index = 0;
    while (index < text.length) {
      final isActive = index >= wordStart! && index < wordEnd!;
      final next = isActive
          ? math.min(wordEnd!, text.length)
          : _nextBoundary(text, index);
      // Phòng infinite loop: nếu không tiến triển thì thoát.
      if (next <= index) break;
      segments.add((text: text.substring(index, next), isActive: isActive));
      index = next;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final segment in segments)
          _AnimatedSpan(
            text: segment.text,
            isActive: segment.isActive,
            style: baseStyle,
          ),
      ],
    );
  }

  /// Vị trí kết thúc "từ" bắt đầu tại [index] — nuốt luôn khoảng trắng/dấu câu
  /// (kể cả `, ; :` và em-dash) để span không bị fragment lạ.
  int _nextBoundary(String text, int index) {
    var i = index;
    while (i < text.length) {
      final char = text[i];
      if (char == ' ' ||
          char == '!' ||
          char == '?' ||
          char == '.' ||
          char == ',' ||
          char == ';' ||
          char == ':' ||
          char == '\u2014') {
        return i + 1; // tiến ít nhất 1 ký tự.
      }
      i++;
    }
    return text.length;
  }
}

/// Span đang đọc — scale 1.08 + màu accent, animate 160ms easeOut
/// (giống `_TermSpan` của study word_card.dart).
class _AnimatedSpan extends StatelessWidget {
  const _AnimatedSpan({
    required this.text,
    required this.isActive,
    required this.style,
  });

  final String text;
  final bool isActive;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.08 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        style: isActive
            ? (style ?? const TextStyle()).copyWith(color: AppColors.accent)
            : style ?? const TextStyle(),
        child: Text(text),
      ),
    );
  }
}

/// Nút chờ khi hết turn — sẽ được thay bằng màn summary.
class _SummaryPlaceholder extends StatelessWidget {
  const _SummaryPlaceholder({
    required this.usedTargetWords,
    required this.onFinish,
  });

  final Set<String> usedTargetWords;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon('check-circle', size: 56, color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Buổi luyện đã xong!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã dùng ${usedTargetWords.length} từ mới.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Xem kết quả',
              onPressed: onFinish,
            ),          ],
        ),
      ),
    );
  }
}
