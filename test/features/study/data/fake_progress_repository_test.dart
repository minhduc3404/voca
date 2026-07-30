import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/data/fake_progress_repository.dart';
import 'package:voca_app/features/study/domain/srs_scheduler.dart';
import 'package:voca_app/features/study/domain/study_rating.dart';

void main() {
  final seededAt = DateTime(2026, 1, 15, 8, 0);

  group('FakeProgressRepository', () {
    test('seed cards đều due ngay khi khởi tạo', () async {
      final repo = FakeProgressRepository(seededAt: seededAt);

      final due = await repo.getDueCards(seededAt);

      expect(due, isNotEmpty);
    });

    test('12. Persist rồi reload → lịch không đổi', () async {
      final repo = FakeProgressRepository(seededAt: seededAt);
      final due = await repo.getDueCards(seededAt);
      final card = due.first;

      final before = await repo.getProgress(card.id);
      final updated = scheduleNextReview(
        current: before,
        rating: StudyRating.good,
        now: seededAt,
      );
      await repo.recordAnswer(updated);

      // "reload" — đọc lại từ repository thay vì dùng biến `updated` có sẵn.
      final reloaded = await repo.getProgress(card.id);

      expect(reloaded, updated);
      expect(reloaded.nextReview, updated.nextReview);
    });

    test('recordAnswer đẩy thẻ ra khỏi danh sách due tới nextReview', () async {
      final repo = FakeProgressRepository(seededAt: seededAt);
      final due = await repo.getDueCards(seededAt);
      final card = due.first;

      final progress = await repo.getProgress(card.id);
      final updated = scheduleNextReview(
        current: progress,
        rating: StudyRating.good,
        now: seededAt,
      );
      await repo.recordAnswer(updated);

      final dueRightAfter = await repo.getDueCards(seededAt);
      expect(dueRightAfter.any((c) => c.id == card.id), isFalse);

      final dueAfterInterval = await repo.getDueCards(updated.nextReview);
      expect(dueAfterInterval.any((c) => c.id == card.id), isTrue);
    });
  });
}
