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

/// Script player — transcript đầy đủ hội thoại (mở màn thấy hết các câu,
/// không hé lộ dần). Câu đang focus tự phát TTS + highlight từ + hiện bản
/// dịch. Điều hướng: chạm 1 câu bất kỳ (freehand) hoặc nút Next/Previous.
/// MVP tập trung nghe hiểu — không có ASR, không chọn câu trả lời.
class ConversationPlayScreen extends ConsumerStatefulWidget {
  const ConversationPlayScreen({required this.script, super.key});

  final ConversationScript script;

  @override
  ConsumerState<ConversationPlayScreen> createState() =>
      _ConversationPlayScreenState();
}

class _ConversationPlayScreenState
    extends ConsumerState<ConversationPlayScreen> {
  late final List<GlobalKey> _turnKeys;

  @override
  void initState() {
    super.initState();
    _turnKeys = List.generate(widget.script.turns.length, (_) => GlobalKey());
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
    // Câu focus đổi (kể cả lần nạp đầu) → tự phát TTS + cuộn transcript tới
    // câu đó. Đặt trong build (không phải initState) vì áp dụng cho MỌI turn,
    // không riêng turn app như thiết kế cũ.
    ref.listen<ScriptPlayState>(scriptPlayerControllerProvider, (
      previous,
      next,
    ) {
      final turn = next.focusedTurn;
      if (turn == null) return;
      final isNewFocus =
          previous == null ||
          previous.script == null ||
          previous.focusedIndex != next.focusedIndex;
      if (!isNewFocus) return;
      ref.read(ttsTurnHighlightControllerProvider.notifier).speak(turn.text);
      _scrollToFocused(next.focusedIndex);
    });

    final playState = ref.watch(scriptPlayerControllerProvider);
    final script = playState.script;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.script.titleVi),
        leading: BackButton(onPressed: () => _confirmExit(context)),
      ),
      body: script == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(script, playState),
    );
  }

  Widget _buildBody(ConversationScript script, ScriptPlayState playState) {
    final focusedTurn = playState.focusedTurn;
    final focusedVocab = focusedTurn == null
        ? const <TargetVocabItem>[]
        : script.vocabForTurn(focusedTurn);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: script.turns.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final turn = script.turns[index];
                return _TurnBubble(
                  key: _turnKeys[index],
                  script: script,
                  turn: turn,
                  isFocused: index == playState.focusedIndex,
                  onTap: () => ref
                      .read(scriptPlayerControllerProvider.notifier)
                      .focusTurn(index),
                );
              },
            ),
          ),
          _BottomBar(
            script: script,
            playState: playState,
            focusedVocab: focusedVocab,
          ),
        ],
      ),
    );
  }

  void _scrollToFocused(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bubbleContext = _turnKeys[index].currentContext;
      if (bubbleContext == null) return;
      Scrollable.ensureVisible(
        bubbleContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
}

/// Một bong bóng thoại trong transcript — role app căn trái, role user căn
/// phải (pattern chat quen thuộc). Câu đang focus mới render highlight TTS +
/// bản dịch (các câu khác chỉ hiện text để đỡ rebuild khi highlight đổi).
class _TurnBubble extends StatelessWidget {
  const _TurnBubble({
    required this.script,
    required this.turn,
    required this.isFocused,
    required this.onTap,
    super.key,
  });

  final ConversationScript script;
  final ConversationTurn turn;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isApp = turn.isAppTurn;
    final role = isApp ? script.appRole : script.userRole;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: isApp
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            role.nameVi,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textFaint),
          ),
        ),
        Material(
          color: isFocused
              ? AppColors.accent.withValues(alpha: .18)
              : AppColors.controlBg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: isFocused
                    ? _FocusedTurnContent(turn: turn)
                    : Text(turn.text, style: textTheme.bodyLarge),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Nội dung câu đang focus — highlight từ theo TTS + bản dịch + nút nghe
/// lại. Tách riêng để chỉ subtree này rebuild theo highlight, không kéo cả
/// transcript.
class _FocusedTurnContent extends ConsumerWidget {
  const _FocusedTurnContent({required this.turn});

  final ConversationTurn turn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlight = ref.watch(ttsTurnHighlightControllerProvider);
    final controller = ref.read(ttsTurnHighlightControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _HighlightedText(
          text: turn.text,
          wordStart: highlight.wordStart,
          wordEnd: highlight.wordEnd,
          style: textTheme.bodyLarge?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 6),
        Text(
          turn.textVi,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Nghe lại',
            visualDensity: VisualDensity.compact,
            icon: AppIcon('volume-up', size: 18, color: AppColors.controlIcon),
            onPressed: () => controller.speak(turn.text),
          ),
        ),
      ],
    );
  }
}

/// Bottom bar: từ khó của câu đang focus + Next/Previous + CTA tổng kết khi
/// tới câu cuối.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.script,
    required this.playState,
    required this.focusedVocab,
  });

  final ConversationScript script;
  final ScriptPlayState playState;
  final List<TargetVocabItem> focusedVocab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(scriptPlayerControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.controlBg, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (focusedVocab.isNotEmpty) ...[
              Text(
                'Từ khó trong câu này',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textFaint,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final vocab in focusedVocab) _VocabChip(vocab: vocab),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Câu trước',
                  icon: AppIcon(
                    'skip-prev',
                    size: 24,
                    color: playState.isFirst
                        ? AppColors.textFaint
                        : AppColors.controlIcon,
                  ),
                  onPressed: playState.isFirst ? null : notifier.previous,
                ),
                Text(
                  '${playState.focusedIndex + 1}/${script.turns.length}',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textFaint,
                  ),
                ),
                IconButton(
                  tooltip: 'Câu tiếp',
                  icon: AppIcon(
                    'skip-next',
                    size: 24,
                    color: playState.isLast
                        ? AppColors.textFaint
                        : AppColors.controlIcon,
                  ),
                  onPressed: playState.isLast ? null : notifier.next,
                ),
              ],
            ),
            if (playState.isLast) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Xem tổng kết',
                onPressed: () => _goToSummary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _goToSummary(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationSummaryScreen(script: script),
      ),
    );
  }
}

class _VocabChip extends StatelessWidget {
  const _VocabChip({required this.vocab});

  final TargetVocabItem vocab;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vocab.term,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          Text(
            vocab.senseVi,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textFaint),
          ),
        ],
      ),
    );
  }
}

/// Render text turn, tô sáng từ đang đọc (word boundary) — có animation
/// scale + màu theo pattern `_TermSpan` của study (word_card.dart):
/// `AnimatedScale` + `AnimatedDefaultTextStyle` (160ms easeOut).
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.wordStart,
    required this.wordEnd,
    this.style,
  });

  final String text;
  final int? wordStart;
  final int? wordEnd;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (wordStart == null || wordEnd == null) {
      return Text(text, style: style);
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
            style: style,
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
          char == '—') {
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
