class WordProgress {
  const WordProgress({
    required this.cardId,
    required this.interval,
    required this.easeFactor,
    required this.reps,
    required this.lapses,
    required this.nextReview,
    this.lastReview,
  });

  /// Trạng thái ban đầu cho một thẻ chưa từng được ôn — xem ADR-010.
  factory WordProgress.initial({required int cardId, required DateTime now}) {
    return WordProgress(
      cardId: cardId,
      interval: 0,
      easeFactor: 2.5,
      reps: 0,
      lapses: 0,
      nextReview: now,
      lastReview: null,
    );
  }

  final int cardId;
  final int interval;
  final double easeFactor;
  final int reps;
  final int lapses;
  final DateTime nextReview;
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
    lastReview,
  );
}
