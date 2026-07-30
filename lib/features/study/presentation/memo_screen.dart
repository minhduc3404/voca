import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/l10n/arb/app_localizations.dart';

import '../application/providers.dart';
import '../application/session_controller.dart';
import '../domain/study_rating.dart';
import '../domain/word_progress.dart';
import 'widgets/control_bar.dart';
import 'widgets/word_card.dart';

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

  Future<void> _handleRating(StudyRating rating) async {
    setState(() => _showSaved = true);
    await ref.read(sessionControllerProvider.notifier).submitAnswer(rating);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showSaved = false);
  }

  String? _labelFor(
    Map<StudyRating, WordProgress> previews,
    StudyRating rating,
    DateTime now,
  ) {
    final outcome = previews[rating];
    if (outcome == null) return null;
    return _formatReviewDelay(outcome.nextReview.difference(now));
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: WordCard(
              card: card,
              onSpeak: () => ref.read(ttsServiceProvider).speak(card.term),
            ),
          ),
          const SizedBox(height: 16),
          ControlBar(
            onAgain: () => _handleRating(StudyRating.again),
            onHard: () => _handleRating(StudyRating.hard),
            onGood: () => _handleRating(StudyRating.good),
            onEasy: () => _handleRating(StudyRating.easy),
            againLabel: _labelFor(previews, StudyRating.again, now),
            hardLabel: _labelFor(previews, StudyRating.hard, now),
            goodLabel: _labelFor(previews, StudyRating.good, now),
            easyLabel: _labelFor(previews, StudyRating.easy, now),
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
