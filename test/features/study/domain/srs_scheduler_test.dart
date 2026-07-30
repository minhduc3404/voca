import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/domain/srs_scheduler.dart';
import 'package:voca_app/features/study/domain/study_rating.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';

void main() {
  final anchor = DateTime(2026, 1, 15, 10, 0);

  WordProgress newCard(DateTime now) =>
      WordProgress.initial(cardId: 1, now: now);

  group('scheduleNextReview — learning phase (ADR-011)', () {
    test('1. Thẻ mới → Good lần 1 → sang bước kế, CHƯA graduate', () {
      final result = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      );

      expect(result.learningStep, 1); // learningStepsMinutes[1] = 10 phút
      expect(result.reps, 0); // chưa graduate, reps chưa tăng
      expect(result.easeFactor, 2.5); // ease không đổi trong learning
      expect(result.nextReview, anchor.add(const Duration(minutes: 10)));
    });

    test('2. Thẻ mới → Good 2 lần liên tiếp (đủ số bước) → graduate', () {
      final step1 = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      );
      final graduated = scheduleNextReview(
        current: step1,
        rating: StudyRating.good,
        now: step1.nextReview,
      );

      expect(graduated.learningStep, isNull);
      expect(graduated.interval, 1); // graduating interval (Good) = 1 ngày
      expect(graduated.reps, 1);
      expect(
        graduated.nextReview,
        step1.nextReview.add(const Duration(days: 1)),
      );
    });

    test('3. Thẻ mới → Easy → graduate NGAY, bỏ qua các bước còn lại', () {
      final result = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.easy,
        now: anchor,
      );

      expect(result.learningStep, isNull);
      expect(result.interval, 4); // graduating interval (Easy) = 4 ngày
      expect(result.reps, 1);
      expect(result.nextReview, anchor.add(const Duration(days: 4)));
    });

    test('4. Thẻ mới → Again → quay lại bước đầu, KHÔNG tính là lapse', () {
      final result = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.again,
        now: anchor,
      );

      expect(result.learningStep, 0);
      expect(result.lapses, 0); // chưa từng graduate → không phải lapse thật
      expect(result.reps, 0);
      expect(result.nextReview, anchor.add(const Duration(minutes: 1)));
    });

    test('5. Hard trong learning phase → lặp lại bước hiện tại', () {
      final step1 = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor,
      ); // learningStep = 1 (10 phút)

      final result = scheduleNextReview(
        current: step1,
        rating: StudyRating.hard,
        now: step1.nextReview,
      );

      expect(result.learningStep, 1); // vẫn ở bước 1, không tiến không lùi
      expect(result.nextReview, step1.nextReview.add(const Duration(minutes: 10)));
    });

    test('9. easeFactor không đổi dù Again/Hard nhiều lần trong learning', () {
      final afterAgain = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.again,
        now: anchor,
      );
      final afterHard = scheduleNextReview(
        current: afterAgain,
        rating: StudyRating.hard,
        now: afterAgain.nextReview,
      );

      expect(afterAgain.easeFactor, 2.5);
      expect(afterHard.easeFactor, 2.5);
    });
  });

  group('scheduleNextReview — review phase (ADR-010, sau khi graduate)', () {
    WordProgress graduatedCard(DateTime now) {
      final step1 = scheduleNextReview(
        current: newCard(now),
        rating: StudyRating.good,
        now: now,
      );
      return scheduleNextReview(
        current: step1,
        rating: StudyRating.good,
        now: step1.nextReview,
      ); // interval = 1 ngày, reps = 1
    }

    test('6. Review đúng liên tiếp (interval tăng dần)', () {
      final graduated = graduatedCard(anchor);
      final t1 = graduated.nextReview;

      final progress2 = scheduleNextReview(
        current: graduated,
        rating: StudyRating.good,
        now: t1,
      );
      final progress3 = scheduleNextReview(
        current: progress2,
        rating: StudyRating.good,
        now: progress2.nextReview,
      );

      expect(progress2.interval, 3); // round(1 * 2.5)
      expect(progress3.interval, 8); // round(3 * 2.5)
      expect(progress3.interval, greaterThan(progress2.interval));
    });

    test('7. Lapse thật (Again sau khi đã graduate) → vào lại relearning', () {
      final graduated = graduatedCard(anchor);
      final t1 = graduated.nextReview;
      final reviewed = scheduleNextReview(
        current: graduated,
        rating: StudyRating.good,
        now: t1,
      ); // interval = 3 ngày

      final lapsed = scheduleNextReview(
        current: reviewed,
        rating: StudyRating.again,
        now: reviewed.nextReview,
      );

      expect(lapsed.learningStep, 0);
      expect(lapsed.lapses, 1);
      expect(lapsed.reps, 0);
      expect(lapsed.easeFactor, closeTo(2.3, 1e-9)); // 2.5 - 0.20
      expect(
        lapsed.nextReview,
        reviewed.nextReview.add(const Duration(minutes: 1)),
      );
    });

    test('8. Sau lapse, graduate lại từ đầu (không dùng interval cũ)', () {
      final graduated = graduatedCard(anchor);
      final lapsed = scheduleNextReview(
        current: graduated,
        rating: StudyRating.again,
        now: graduated.nextReview,
      );

      final step1 = scheduleNextReview(
        current: lapsed,
        rating: StudyRating.good,
        now: lapsed.nextReview,
      );
      final regraduated = scheduleNextReview(
        current: step1,
        rating: StudyRating.good,
        now: step1.nextReview,
      );

      expect(regraduated.learningStep, isNull);
      expect(regraduated.interval, 1); // graduate lại từ đầu, không phải x2.5
      expect(regraduated.reps, 1);
    });

    test('10. Maximum interval (không vượt quá 365)', () {
      final current = WordProgress(
        cardId: 1,
        interval: 300,
        easeFactor: 2.5,
        reps: 5,
        lapses: 0,
        learningStep: null,
        nextReview: anchor,
      );

      final result = scheduleNextReview(
        current: current,
        rating: StudyRating.easy,
        now: anchor,
      );

      // round(300 * 2.5 * 1.3) = 975 → cắt về trần 365.
      expect(result.interval, 365);
    });
  });

  group('scheduleNextReview — bất biến chung', () {
    test('11. Không mutate input object', () {
      final current = newCard(anchor);
      final snapshotStep = current.learningStep;
      final snapshotEase = current.easeFactor;

      final result = scheduleNextReview(
        current: current,
        rating: StudyRating.good,
        now: anchor,
      );

      expect(current.learningStep, snapshotStep);
      expect(current.easeFactor, snapshotEase);
      expect(identical(result, current), isFalse);
    });

    test('12. Cùng input → cùng output (deterministic)', () {
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

    test('13. Review sớm/trễ không có logic đặc biệt (kể cả learning phase)', () {
      final early = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor.add(const Duration(seconds: 1)),
      );
      final late = scheduleNextReview(
        current: newCard(anchor),
        rating: StudyRating.good,
        now: anchor.add(const Duration(days: 10)),
      );

      // Cùng công thức, chỉ khác mốc `now` truyền vào.
      expect(early.learningStep, 1);
      expect(late.learningStep, 1);
    });
  });
}
