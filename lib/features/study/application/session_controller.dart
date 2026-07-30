import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/srs_scheduler.dart';
import '../domain/study_card.dart';
import '../domain/study_rating.dart';
import 'providers.dart';

class StudySessionState {
  const StudySessionState({required this.dueCards, required this.currentIndex});

  final List<StudyCard> dueCards;
  final int currentIndex;

  StudyCard? get currentCard =>
      currentIndex < dueCards.length ? dueCards[currentIndex] : null;

  bool get isCompleted => currentCard == null;

  StudySessionState copyWith({List<StudyCard>? dueCards, int? currentIndex}) {
    return StudySessionState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class SessionController extends AsyncNotifier<StudySessionState> {
  @override
  Future<StudySessionState> build() async {
    final repository = ref.watch(progressRepositoryProvider);
    final dueCards = await repository.getDueCards(DateTime.now());
    return StudySessionState(dueCards: dueCards, currentIndex: 0);
  }

  /// Ghi nhận câu trả lời cho thẻ hiện tại rồi chuyển sang thẻ tiếp theo.
  Future<void> submitAnswer(StudyRating rating) async {
    final current = state.value;
    final card = current?.currentCard;
    if (current == null || card == null) return;

    final repository = ref.read(progressRepositoryProvider);
    final now = DateTime.now();
    final progress = await repository.getProgress(card.id);
    final updated = scheduleNextReview(
      current: progress,
      rating: rating,
      now: now,
    );
    await repository.recordAnswer(updated);

    state = AsyncData(current.copyWith(currentIndex: current.currentIndex + 1));
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, StudySessionState>(
      SessionController.new,
    );
