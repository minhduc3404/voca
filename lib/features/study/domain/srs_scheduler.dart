import 'study_rating.dart';
import 'word_progress.dart';

/// Learning/relearning steps (phút) — dùng chung cho thẻ mới lẫn relearning
/// sau lapse, xem ADR-011.
const List<int> learningStepsMinutes = [1, 10];

const int _goodGraduatingIntervalDays = 1;
const int _easyGraduatingIntervalDays = 4;
const double _minEaseFactor = 1.3;
const int _maxIntervalDays = 365;

/// Thuật toán SM-2 + learning steps đã chốt ở ADR-010/ADR-011. Hàm thuần:
/// không mutate [current], không tự gọi `DateTime.now()` — clock luôn được
/// truyền qua [now].
WordProgress scheduleNextReview({
  required WordProgress current,
  required StudyRating rating,
  required DateTime now,
}) {
  if (current.learningStep != null) {
    return _scheduleWithinLearning(current, rating, now);
  }
  return _scheduleWithinReview(current, rating, now);
}

WordProgress _scheduleWithinLearning(
  WordProgress current,
  StudyRating rating,
  DateTime now,
) {
  switch (rating) {
    case StudyRating.again:
      return WordProgress(
        cardId: current.cardId,
        interval: current.interval,
        easeFactor: current.easeFactor,
        reps: current.reps,
        lapses: current.lapses,
        learningStep: 0,
        nextReview: now.add(Duration(minutes: learningStepsMinutes[0])),
        lastReview: now,
      );
    case StudyRating.hard:
      final step = current.learningStep!;
      return WordProgress(
        cardId: current.cardId,
        interval: current.interval,
        easeFactor: current.easeFactor,
        reps: current.reps,
        lapses: current.lapses,
        learningStep: step,
        nextReview: now.add(Duration(minutes: learningStepsMinutes[step])),
        lastReview: now,
      );
    case StudyRating.good:
      final nextStep = current.learningStep! + 1;
      if (nextStep < learningStepsMinutes.length) {
        return WordProgress(
          cardId: current.cardId,
          interval: current.interval,
          easeFactor: current.easeFactor,
          reps: current.reps,
          lapses: current.lapses,
          learningStep: nextStep,
          nextReview: now.add(
            Duration(minutes: learningStepsMinutes[nextStep]),
          ),
          lastReview: now,
        );
      }
      return _graduate(
        current,
        now,
        intervalDays: _goodGraduatingIntervalDays,
      );
    case StudyRating.easy:
      return _graduate(current, now, intervalDays: _easyGraduatingIntervalDays);
  }
}

WordProgress _graduate(
  WordProgress current,
  DateTime now, {
  required int intervalDays,
}) {
  return WordProgress(
    cardId: current.cardId,
    interval: intervalDays,
    easeFactor: current.easeFactor,
    reps: 1,
    lapses: current.lapses,
    learningStep: null,
    nextReview: now.add(Duration(days: intervalDays)),
    lastReview: now,
  );
}

WordProgress _scheduleWithinReview(
  WordProgress current,
  StudyRating rating,
  DateTime now,
) {
  if (rating == StudyRating.again) {
    // Lapse thật (thẻ đã graduate trước đó) — vào lại relearning.
    return WordProgress(
      cardId: current.cardId,
      interval: current.interval,
      easeFactor: _nextEaseFactor(current.easeFactor, StudyRating.again),
      reps: 0,
      lapses: current.lapses + 1,
      learningStep: 0,
      nextReview: now.add(Duration(minutes: learningStepsMinutes[0])),
      lastReview: now,
    );
  }

  // Hard/Good/Easy — công thức SM-2 theo NGÀY, y hệt ADR-010.
  final rawInterval = _reviewIntervalDays(
    current.interval,
    current.easeFactor,
    rating,
  );
  final interval = rawInterval > _maxIntervalDays
      ? _maxIntervalDays
      : rawInterval;
  final easeFactor = _nextEaseFactor(current.easeFactor, rating);

  return WordProgress(
    cardId: current.cardId,
    interval: interval,
    easeFactor: easeFactor,
    reps: current.reps + 1,
    lapses: current.lapses,
    learningStep: null,
    nextReview: now.add(Duration(days: interval)),
    lastReview: now,
  );
}

double _nextEaseFactor(double current, StudyRating rating) {
  final delta = switch (rating) {
    StudyRating.again => -0.20,
    StudyRating.hard => -0.15,
    StudyRating.good => 0.0,
    StudyRating.easy => 0.15,
  };
  final next = current + delta;
  return next < _minEaseFactor ? _minEaseFactor : next;
}

int _reviewIntervalDays(
  int previousInterval,
  double easeFactor,
  StudyRating rating,
) {
  return switch (rating) {
    StudyRating.again => 1, // không dùng thực tế — Again luôn rẽ nhánh lapse ở trên
    StudyRating.hard => _atLeast(
      (previousInterval * 1.2).round(),
      previousInterval + 1,
    ),
    StudyRating.good => (previousInterval * easeFactor).round(),
    StudyRating.easy => (previousInterval * easeFactor * 1.3).round(),
  };
}

int _atLeast(int value, int minimum) => value > minimum ? value : minimum;
