import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/domain/srs_scheduler.dart';
import 'package:voca_app/features/study/domain/study_rating.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';

void main() {
  final anchor = DateTime(2026, 1, 15, 10, 0);

  WordProgress newCard(DateTime now) =>
      WordProgress.initial(cardId: 1, now: now);

  group('scheduleNextReview — test matrix PLAN-PHASE-1-2.md', () {
    test('1. Từ mới → trả lời đúng (Good)', () {
      final result = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      );

      expect(result.interval, 1);
      expect(result.reps, 1);
      expect(result.lapses, 0);
      expect(result.easeFactor, 2.5);
      expect(result.nextReview, anchor.add(const Duration(days: 1)));
      expect(result.lastReview, anchor);
    });

    test('2. Từ mới → trả lời sai (Again)', () {
      final result = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.again,
        now: anchor,
      );

      expect(result.interval, 1);
      expect(result.reps, 0);
      expect(result.lapses, 1);
      expect(result.easeFactor, closeTo(2.3, 1e-9));
    });

    test('3. Review đúng liên tiếp (interval tăng dần)', () {
      final t0 = anchor;
      final progress1 = scheduleNextReview(
        current: newCard(t0),
        rating: StudyRating.good,
        now: t0,
      );
      final t1 = progress1.nextReview;
      final progress2 = scheduleNextReview(
        current: progress1,
        rating: StudyRating.good,
        now: t1,
      );
      final t2 = progress2.nextReview;
      final progress3 = scheduleNextReview(
        current: progress2,
        rating: StudyRating.good,
        now: t2,
      );

      expect(progress1.interval, 1);
      expect(progress2.interval, 3); // round(1 * 2.5)
      expect(progress3.interval, 8); // round(3 * 2.5)
      expect(progress2.interval, greaterThan(progress1.interval));
      expect(progress3.interval, greaterThan(progress2.interval));
    });

    test('4. Lapse sau chuỗi đúng (interval reset)', () {
      final t0 = anchor;
      final progress1 = scheduleNextReview(
        current: newCard(t0),
        rating: StudyRating.good,
        now: t0,
      );
      final progress2 = scheduleNextReview(
        current: progress1,
        rating: StudyRating.good,
        now: progress1.nextReview,
      );
      final progress3 = scheduleNextReview(
        current: progress2,
        rating: StudyRating.good,
        now: progress2.nextReview,
      );

      final lapsed = scheduleNextReview(
        current: progress3,
        rating: StudyRating.again,
        now: progress3.nextReview,
      );

      expect(progress3.interval, greaterThan(1));
      expect(lapsed.interval, 1);
      expect(lapsed.reps, 0);
      expect(lapsed.lapses, progress3.lapses + 1);
    });

    test('5. Review sớm (trước nextReview) — không có logic đặc biệt', () {
      final progress1 = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      );
      // progress1.nextReview = anchor + 1 ngày; review sớm 12 giờ trước hạn.
      final early = anchor.add(const Duration(hours: 12));

      final result = scheduleNextReview(
        current: progress1,
        rating: StudyRating.good,
        now: early,
      );

      // Công thức chỉ phụ thuộc rating + interval/ease cũ, không phụ thuộc
      // việc `now` sớm hay trễ so với `current.nextReview`.
      expect(result.interval, 3); // round(1 * 2.5), giống hệt review đúng hạn
      expect(result.nextReview, early.add(const Duration(days: 3)));
    });

    test('6. Review trễ (sau nextReview) — không có logic đặc biệt', () {
      final progress1 = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      );
      // progress1.nextReview = anchor + 1 ngày; review trễ 5 ngày sau hạn.
      final late = anchor.add(const Duration(days: 6));

      final result = scheduleNextReview(
        current: progress1,
        rating: StudyRating.good,
        now: late,
      );

      expect(result.interval, 3); // độ trễ không ảnh hưởng công thức interval
      expect(result.nextReview, late.add(const Duration(days: 3)));
    });

    test('7. Boundary trước/sau nửa đêm', () {
      final beforeMidnight = DateTime(2026, 1, 15, 23, 59);

      final result = scheduleNextReview(
        current: newCard(beforeMidnight),
        rating: StudyRating.good,
        now: beforeMidnight,
      );

      // Cộng thẳng Duration, không quy tròn về đầu ngày.
      expect(result.nextReview, DateTime(2026, 1, 16, 23, 59));
    });

    test('8. Timezone / DST — domain không tự diễn giải lịch', () {
      final utcNow = DateTime.utc(2026, 1, 15, 23, 59);

      final result = scheduleNextReview(
        current: newCard(utcNow),
        rating: StudyRating.good,
        now: utcNow,
      );

      expect(result.nextReview.isUtc, isTrue);
      expect(result.nextReview, utcNow.add(const Duration(days: 1)));
    });

    test('9. Maximum interval (không vượt quá 365)', () {
      final current = WordProgress(
        cardId: 1,
        interval: 300,
        easeFactor: 2.5,
        reps: 5,
        lapses: 0,
        nextReview: anchor,
      );

      final result = scheduleNextReview(
        current: current,
        rating: StudyRating.easy,
        now: anchor,
      );

      // round(300 * 2.5 * 1.3) = 975 → cắt về trần 365.
      expect(result.interval, 365);
      expect(result.nextReview, anchor.add(const Duration(days: 365)));
    });

    test('10. Không mutate input object', () {
      final current = newCard(anchor);
      final snapshotInterval = current.interval;
      final snapshotEase = current.easeFactor;
      final snapshotReps = current.reps;
      final snapshotLapses = current.lapses;
      final snapshotNextReview = current.nextReview;

      final result = scheduleNextReview(
        current: current,
        rating: StudyRating.good,
        now: anchor,
      );

      expect(current.interval, snapshotInterval);
      expect(current.easeFactor, snapshotEase);
      expect(current.reps, snapshotReps);
      expect(current.lapses, snapshotLapses);
      expect(current.nextReview, snapshotNextReview);
      expect(identical(result, current), isFalse);
    });

    test('11. Cùng input → cùng output (deterministic)', () {
      final current = newCard(anchor);

      final result1 = scheduleNextReview(
        current: current,
        rating: StudyRating.hard,
        now: anchor,
      );
      final result2 = scheduleNextReview(
        current: current,
        rating: StudyRating.hard,
        now: anchor,
      );

      expect(result1, result2);
    });
  });
}
