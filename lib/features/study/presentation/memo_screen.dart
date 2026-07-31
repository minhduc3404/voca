import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/l10n/arb/app_localizations.dart';

import '../application/providers.dart';
import '../application/session_controller.dart';
import '../domain/study_rating.dart';
import 'tts_settings_screen.dart';
import 'widgets/remember_button.dart';
import 'widgets/word_card.dart';

/// Chế độ rảnh tay: mỗi thẻ hiện tối đa 10s. TTS tự phát ở giây 2 và 6.
/// Bấm "Đã nhớ" trong lúc đếm ngược = Good; hết giờ không bấm = tự động
/// Again rồi chuyển thẻ tiếp theo. Không đổi domain/schema — chỉ là cách
/// UI gọi `submitAnswer` (đã có sẵn từ trước).
const _autoAdvanceDuration = Duration(seconds: 10);
const _firstSpeakDelay = Duration(seconds: 2);
const _secondSpeakDelay = Duration(seconds: 6);

String _formatReviewDelay(Duration delay) {
  if (delay.inHours < 1) {
    final minutes = delay.inMinutes < 1 ? 1 : delay.inMinutes;
    return '$minutes phút';
  }
  if (delay.inHours < 24) {
    return '${delay.inHours} giờ';
  }
  return '${delay.inDays} ngày';
}

class MemoScreen extends ConsumerWidget {
  const MemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionControllerProvider);
    final session = sessionAsync.value;
    final showProgress =
        session != null && !session.isCompleted && session.total > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showProgress
              ? '${session.position} / ${session.total} thẻ'
              : AppLocalizations.of(context)!.appTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_voice),
            tooltip: 'Cài đặt phát âm',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TtsSettingsScreen()),
            ),
          ),
        ],
        bottom: showProgress
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: session.position / session.total,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Đã có lỗi khi tải thẻ học: $error')),
          data: (session) => _SessionBody(session: session),
        ),
      ),
    );
  }
}

class _SessionBody extends ConsumerStatefulWidget {
  const _SessionBody({required this.session});

  final StudySessionState session;

  @override
  ConsumerState<_SessionBody> createState() => _SessionBodyState();
}

class _SessionBodyState extends ConsumerState<_SessionBody> {
  bool _showSaved = false;
  int? _currentCardId;
  Timer? _firstSpeakTimer;
  Timer? _secondSpeakTimer;
  Timer? _autoAdvanceTimer;
  bool? _wakelockEnabled;
  // Không khai báo type tường minh (`WakelockService`) — presentation không
  // được import `data/` trực tiếp (CLAUDE.md §2); type suy ra qua provider.
  late final _wakelockService = ref.read(wakelockServiceProvider);

  @override
  void initState() {
    super.initState();
    _maybeSyncTimers();
    _syncWakelock();
  }

  @override
  void didUpdateWidget(covariant _SessionBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSyncTimers();
    _syncWakelock();
  }

  @override
  void dispose() {
    _cancelTimers();
    if (_wakelockEnabled ?? false) {
      unawaited(_wakelockService.disable());
    }
    super.dispose();
  }

  /// Giữ màn hình sáng trong lúc còn thẻ để ôn — chế độ rảnh tay không có
  /// thao tác chạm thường xuyên nên Android/iOS sẽ tự dim/tắt màn hình theo
  /// timeout OS nếu không có wakelock. Tắt lại khi ôn xong.
  void _syncWakelock() {
    final shouldEnable = !widget.session.isCompleted;
    if (_wakelockEnabled == shouldEnable) return;
    _wakelockEnabled = shouldEnable;
    unawaited(shouldEnable ? _wakelockService.enable() : _wakelockService.disable());
  }

  /// Bắt đầu lại bộ đếm cho thẻ hiện tại — chỉ khi thẻ thực sự đổi và
  /// không đang hiện màn "Đã lưu!" (tránh đếm ngược lúc thẻ chưa hiện ra).
  void _maybeSyncTimers() {
    if (_showSaved) return;
    final card = widget.session.currentCard;
    if (card == null || card.id == _currentCardId) return;

    _currentCardId = card.id;
    _cancelTimers();
    _firstSpeakTimer = Timer(_firstSpeakDelay, () => _speak(card.term));
    _secondSpeakTimer = Timer(_secondSpeakDelay, () => _speak(card.term));
    _autoAdvanceTimer = Timer(
      _autoAdvanceDuration,
      () => _handleRating(StudyRating.again),
    );
  }

  void _speak(String text) => ref.read(ttsServiceProvider).speak(text);

  void _cancelTimers() {
    _firstSpeakTimer?.cancel();
    _secondSpeakTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _firstSpeakTimer = null;
    _secondSpeakTimer = null;
    _autoAdvanceTimer = null;
  }

  Future<void> _handleRating(StudyRating rating) async {
    _cancelTimers();
    setState(() => _showSaved = true);
    await ref.read(sessionControllerProvider.notifier).submitAnswer(rating);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _showSaved = false);
    _maybeSyncTimers();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.session.currentCard;

    if (card == null) {
      return _CompletionView(
        onReload: () =>
            ref.read(sessionControllerProvider.notifier).reload(),
      );
    }

    if (_showSaved) {
      return const _SavedTransition();
    }

    final now = DateTime.now();
    final previews = ref
        .read(sessionControllerProvider.notifier)
        .previewOutcomes(now);
    final goodOutcome = previews[StudyRating.good];
    final goodLabel = goodOutcome == null
        ? null
        : _formatReviewDelay(goodOutcome.nextReview.difference(now));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(card.id),
            tween: Tween(begin: 1.0, end: 0.0),
            duration: _autoAdvanceDuration,
            builder: (context, value, child) =>
                LinearProgressIndicator(value: value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: WordCard(
              card: card,
              onSpeak: () => ref.read(ttsServiceProvider).speak(card.term),
            ),
          ),
          const SizedBox(height: 16),
          RememberButton(
            onPressed: () => _handleRating(StudyRating.good),
            previewLabel: goodLabel,
          ),
        ],
      ),
    );
  }
}

class _SavedTransition extends StatelessWidget {
  const _SavedTransition();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Đã lưu!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Cùng tiến lên nào 💪'),
        ],
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã ôn hết thẻ đến hạn hôm nay',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Quay lại vào ngày mai hoặc thêm từ mới.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onReload,
              child: const Text('Ôn lại từ mới'),
            ),
          ],
        ),
      ),
    );
  }
}
