class WordProgress {
  const WordProgress({
    required this.cardId,
    required this.interval,
    required this.easeFactor,
    required this.reps,
    required this.lapses,
    required this.nextReview,
    required this.learningStep,
    this.lastReview,
  });

  /// Trạng thái ban đầu cho một thẻ chưa từng được ôn — bắt đầu ở learning
  /// phase (`learningStep = 0`), xem ADR-011.
  factory WordProgress.initial({required int cardId, required DateTime now}) {
    return WordProgress(
      cardId: cardId,
      interval: 0,
      easeFactor: 2.5,
      reps: 0,
      lapses: 0,
      nextReview: now,
      learningStep: 0,
      lastReview: null,
    );
  }

  final int cardId;

  /// Số NGÀY tới lần ôn tiếp theo — chỉ có ý nghĩa khi [learningStep] là
  /// `null` (đã graduate, ở review phase). Xem ADR-010/ADR-011.
  final int interval;
  final double easeFactor;
  final int reps;
  final int lapses;
  final DateTime nextReview;

  /// `null` = đã graduate, ở review phase (SM-2 theo ngày).
  /// `0, 1, ...` = đang ở learning/relearning phase, index vào
  /// `learningSteps` (phút) — xem ADR-011.
  final int? learningStep;

  final DateTime? lastReview;

  WordProgress copyWith({
    int? interval,
    double? easeFactor,
    int? reps,
    int? lapses,
    DateTime? nextReview,
    DateTime? lastReview,
  }) {
    return WordProgress(
      cardId: cardId,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      nextReview: nextReview ?? this.nextReview,
      learningStep: learningStep,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordProgress &&
        other.cardId == cardId &&
        other.interval == interval &&
        other.easeFactor == easeFactor &&
        other.reps == reps &&
        other.lapses == lapses &&
        other.nextReview == nextReview &&
        other.learningStep == learningStep &&
        other.lastReview == lastReview;
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    interval,
    easeFactor,
    reps,
    lapses,
    nextReview,
    learningStep,
    lastReview,
  );
}
