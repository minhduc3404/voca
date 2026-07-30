import 'study_rating.dart';
import 'word_progress.dart';

const double _minEaseFactor = 1.3;
const int _maxIntervalDays = 365;

/// Thuật toán SM-2 cổ điển đã chốt ở ADR-010. Hàm thuần: không mutate
/// [current], không tự gọi `DateTime.now()` — clock luôn được truyền qua [now].
WordProgress scheduleNextReview({
  required WordProgress current,
  required StudyRating rating,
  required DateTime now,
}) {
  final isNewCard = current.reps == 0;
  // Interval dùng ease factor CŨ (trước điều chỉnh) — chuẩn SM-2: ease mới
  // chỉ có hiệu lực cho lần ôn kế tiếp, không hồi tố vào lần vừa trả lời.
  final rawInterval = isNewCard
      ? _newCardIntervalDays(rating)
      : _reviewIntervalDays(current.interval, current.easeFactor, rating);
  final interval = rawInterval > _maxIntervalDays
      ? _maxIntervalDays
      : rawInterval;

  final easeFactor = _nextEaseFactor(current.easeFactor, rating);
  final reps = rating == StudyRating.again ? 0 : current.reps + 1;
  final lapses = rating == StudyRating.again
      ? current.lapses + 1
      : current.lapses;

  return current.copyWith(
    interval: interval,
    easeFactor: easeFactor,
    reps: reps,
    lapses: lapses,
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

int _newCardIntervalDays(StudyRating rating) {
  return switch (rating) {
    StudyRating.again => 1,
    StudyRating.hard => 1,
    StudyRating.good => 1,
    StudyRating.easy => 4,
  };
}

int _reviewIntervalDays(
  int previousInterval,
  double easeFactor,
  StudyRating rating,
) {
  return switch (rating) {
    StudyRating.again => 1,
    StudyRating.hard => _atLeast(
      (previousInterval * 1.2).round(),
      previousInterval + 1,
    ),
    StudyRating.good => (previousInterval * easeFactor).round(),
    StudyRating.easy => (previousInterval * easeFactor * 1.3).round(),
  };
}

int _atLeast(int value, int minimum) => value > minimum ? value : minimum;
