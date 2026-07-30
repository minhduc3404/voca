import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/srs_scheduler.dart';
import '../domain/study_card.dart';
import '../domain/study_rating.dart';
import '../domain/word_progress.dart';
import 'providers.dart';

class StudySessionState {
  const StudySessionState({
    required this.dueCards,
    required this.currentIndex,
    required this.currentProgress,
  });

  final List<StudyCard> dueCards;
  final int currentIndex;

  /// Tiến độ SRS của thẻ hiện tại — dùng để tính preview interval trên nút
  /// rating (mockup UI). `null` khi đã hết thẻ.
  final WordProgress? currentProgress;

  StudyCard? get currentCard =>
      currentIndex < dueCards.length ? dueCards[currentIndex] : null;

  bool get isCompleted => currentCard == null;

  /// Vị trí thẻ hiện tại (1-indexed) trong tổng số thẻ due — cho UI hiển
  /// thị "X/Y thẻ". `0` khi đã hết thẻ.
  int get position => isCompleted ? dueCards.length : currentIndex + 1;

  int get total => dueCards.length;
}

class SessionController extends AsyncNotifier<StudySessionState> {
  @override
  Future<StudySessionState> build() async {
    final repository = ref.watch(progressRepositoryProvider);
    final dueCards = await repository.getDueCards(DateTime.now());
    final progress = dueCards.isEmpty
        ? null
        : await repository.getProgress(dueCards.first.id);
    return StudySessionState(
      dueCards: dueCards,
      currentIndex: 0,
      currentProgress: progress,
    );
  }

  /// Preview kết quả nếu bấm từng rating — KHÔNG ghi vào repository, chỉ để
  /// hiển thị nhãn trên nút (mockup UI). Domain logic thuần vẫn nằm ở
  /// application, presentation chỉ nhận kết quả (model) qua đây.
  Map<StudyRating, WordProgress> previewOutcomes(DateTime now) {
    final progress = state.value?.currentProgress;
    if (progress == null) return const {};
    return {
      for (final rating in StudyRating.values)
        rating: scheduleNextReview(current: progress, rating: rating, now: now),
    };
  }

  /// Ghi nhận câu trả lời cho thẻ hiện tại rồi chuyển sang thẻ tiếp theo.
  Future<void> submitAnswer(StudyRating rating) async {
    final current = state.value;
    final card = current?.currentCard;
    final progress = current?.currentProgress;
    if (current == null || card == null || progress == null) return;

    final repository = ref.read(progressRepositoryProvider);
    final now = DateTime.now();
    final updated = scheduleNextReview(
      current: progress,
      rating: rating,
      now: now,
    );
    await repository.recordAnswer(updated);

    final nextIndex = current.currentIndex + 1;
    final nextCard = nextIndex < current.dueCards.length
        ? current.dueCards[nextIndex]
        : null;
    final nextProgress = nextCard == null
        ? null
        : await repository.getProgress(nextCard.id);

    state = AsyncData(
      StudySessionState(
        dueCards: current.dueCards,
        currentIndex: nextIndex,
        currentProgress: nextProgress,
      ),
    );
  }

  /// Nạp lại danh sách thẻ due — dùng cho nút "Ôn lại từ mới" ở màn hoàn
  /// thành (một số thẻ interval ngắn có thể đã due lại).
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, StudySessionState>(
      SessionController.new,
    );
