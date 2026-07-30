import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/l10n/arb/app_localizations.dart';

import '../application/providers.dart';
import '../application/session_controller.dart';
import '../domain/study_rating.dart';
import 'widgets/control_bar.dart';
import 'widgets/word_card.dart';

class MemoScreen extends ConsumerWidget {
  const MemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
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

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session});

  final StudySessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = session.currentCard;
    if (card == null) {
      return const Center(child: Text('Đã ôn hết thẻ đến hạn hôm nay.'));
    }

    final controller = ref.read(sessionControllerProvider.notifier);

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
            onAgain: () => controller.submitAnswer(StudyRating.again),
            onHard: () => controller.submitAnswer(StudyRating.hard),
            onGood: () => controller.submitAnswer(StudyRating.good),
            onEasy: () => controller.submitAnswer(StudyRating.easy),
          ),
        ],
      ),
    );
  }
}
