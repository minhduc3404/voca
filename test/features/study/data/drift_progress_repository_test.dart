import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/features/study/data/drift_progress_repository.dart';
import 'package:voca_app/features/study/domain/srs_scheduler.dart';
import 'package:voca_app/features/study/domain/study_rating.dart';

void main() {
  late AppDatabase db;
  late DriftProgressRepository repository;
  final seededAt = DateTime(2026, 1, 15, 8, 0);

  Future<int> insertVocab(String term) {
    return db
        .into(db.vocabularyTable)
        .insert(
          VocabularyTableCompanion.insert(
            term: term,
            definition: '$term (định nghĩa)',
            language: 'en',
            phonetic: '/$term/',
            partOfSpeech: const Value('noun'),
            exampleSentence: 'This is $term.',
            createdAt: seededAt,
          ),
        );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftProgressRepository', () {
    test('thẻ chưa có progress row → due ngay + WordProgress.initial', () async {
      final cardId = await insertVocab('apple');

      final due = await repository.getDueCards(seededAt);
      expect(due.map((c) => c.id), contains(cardId));

      final progress = await repository.getProgress(cardId);
      expect(progress.reps, 0);
      expect(progress.easeFactor, 2.5);
    });

    test('12. Persist rồi reload → lịch không đổi', () async {
      final cardId = await insertVocab('banana');

      final before = await repository.getProgress(cardId);
      final updated = scheduleNextReview(
        current: before,
        rating: StudyRating.good,
        now: seededAt,
      );
      await repository.recordAnswer(updated);

      // "reload" — đọc lại từ repository (tức từ DB) thay vì dùng `updated`.
      final reloaded = await repository.getProgress(cardId);

      expect(reloaded.interval, updated.interval);
      expect(reloaded.easeFactor, updated.easeFactor);
      expect(reloaded.reps, updated.reps);
      expect(reloaded.lapses, updated.lapses);
      expect(reloaded.nextReview, updated.nextReview);
    });

    test('recordAnswer đẩy thẻ ra khỏi due tới nextReview', () async {
      final cardId = await insertVocab('cherry');

      final progress = await repository.getProgress(cardId);
      final updated = scheduleNextReview(
        current: progress,
        rating: StudyRating.good,
        now: seededAt,
      );
      await repository.recordAnswer(updated);

      final dueRightAfter = await repository.getDueCards(seededAt);
      expect(dueRightAfter.any((c) => c.id == cardId), isFalse);

      final dueAfterInterval = await repository.getDueCards(
        updated.nextReview,
      );
      expect(dueAfterInterval.any((c) => c.id == cardId), isTrue);
    });

    test('recordAnswer lần 2 UPDATE thay vì tạo thêm row mới', () async {
      final cardId = await insertVocab('date');

      final first = await repository.getProgress(cardId);
      final afterGood = scheduleNextReview(
        current: first,
        rating: StudyRating.good,
        now: seededAt,
      );
      await repository.recordAnswer(afterGood);

      final afterAgain = scheduleNextReview(
        current: afterGood,
        rating: StudyRating.again,
        now: afterGood.nextReview,
      );
      await repository.recordAnswer(afterAgain);

      final rows = await db.select(db.progressTable).get();
      expect(rows.where((r) => r.vocabId == cardId).length, 1);

      final finalProgress = await repository.getProgress(cardId);
      // Thẻ vẫn ở learning phase (chưa từng graduate) → Again không phải
      // lapse thật, xem ADR-011.
      expect(finalProgress.reps, 0);
      expect(finalProgress.lapses, 0);
      expect(finalProgress.learningStep, 0);
    });

    test(
      'Restart app → progress không mất (đóng + mở lại kết nối trên cùng file DB)',
      () async {
        final dir = await Directory.systemTemp.createTemp('voca_db_test');
        addTearDown(() => dir.delete(recursive: true));
        final dbFile = File('${dir.path}/voca_restart_test.sqlite');

        var restartDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        final cardId = await restartDb
            .into(restartDb.vocabularyTable)
            .insert(
              VocabularyTableCompanion.insert(
                term: 'fig',
                definition: 'quả sung',
                language: 'en',
                phonetic: '/fig/',
                partOfSpeech: const Value('noun'),
                exampleSentence: 'A ripe fig.',
                createdAt: seededAt,
              ),
            );
        var restartRepo = DriftProgressRepository(restartDb);
        final updated = scheduleNextReview(
          current: await restartRepo.getProgress(cardId),
          rating: StudyRating.good,
          now: seededAt,
        );
        await restartRepo.recordAnswer(updated);
        // Đóng kết nối — mô phỏng app bị kill/restart.
        await restartDb.close();

        // Mở kết nối MỚI trỏ vào cùng file, không dùng lại instance cũ.
        restartDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        restartRepo = DriftProgressRepository(restartDb);
        final reloaded = await restartRepo.getProgress(cardId);

        expect(reloaded.interval, updated.interval);
        expect(reloaded.easeFactor, updated.easeFactor);
        expect(reloaded.nextReview, updated.nextReview);

        await restartDb.close();
      },
    );

    test('join đúng: vocab → domain StudyCard đủ field', () async {
      final cardId = await insertVocab('elderberry');

      final due = await repository.getDueCards(seededAt);
      final card = due.firstWhere((c) => c.id == cardId);

      expect(card.term, 'elderberry');
      expect(card.definition, 'elderberry (định nghĩa)');
      expect(card.phonetic, '/elderberry/');
      expect(card.partOfSpeech, 'noun');
      expect(card.exampleSentence, 'This is elderberry.');
    });
  });
}
