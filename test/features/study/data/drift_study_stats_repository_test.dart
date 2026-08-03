import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/features/study/data/drift_study_log_repository.dart';
import 'package:voca_app/features/study/data/drift_study_stats_repository.dart';

void main() {
  late AppDatabase db;
  late DriftStudyLogRepository logRepo;
  late DriftStudyStatsRepository statsRepo;

  final seededAt = DateTime(2026, 1, 15, 8, 0);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    logRepo = DriftStudyLogRepository(db);
    statsRepo = DriftStudyStatsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertVocab(
    String term, {
    String? catalogId,
  }) {
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
            catalogId: Value(catalogId),
          ),
        );
  }

  Future<void> insertProgress({
    required int vocabId,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? learningStep,
    DateTime? lastReview,
  }) {
    return db.into(db.progressTable).insert(
      ProgressTableCompanion.insert(
        vocabId: vocabId,
        interval: 0,
        easeFactor: 2.5,
        reps: reps ?? 0,
        lapses: lapses ?? 0,
        learningStep: Value(learningStep),
        nextReview: nextReview ?? seededAt,
        lastReview: Value(lastReview),
        createdAt: seededAt,
        updatedAt: seededAt,
      ),
    );
  }

  group('DriftStudyLogRepository', () {
    test('chưa có log → rỗng', () async {
      expect(await logRepo.getStudyDates(), isEmpty);
    });

    test('recordStudy ngày mới → 1 ngày, tăng reviewCount khi ghi tiếp', () async {
      final date = DateTime(2026, 8, 3, 9, 30);
      await logRepo.recordStudy(date: date, isNewWord: true);
      expect(await logRepo.getStudyDates(), {'2026-08-03'});

      final row = await db.select(db.studyLogTable).getSingle();
      expect(row.reviewCount, 1);
      expect(row.newCount, 1);

      // Ghi lại cùng ngày (không phải từ mới) → reviewCount tăng, newCount giữ.
      await logRepo.recordStudy(date: date, isNewWord: false);
      final updated = await db.select(db.studyLogTable).getSingle();
      expect(updated.reviewCount, 2);
      expect(updated.newCount, 1);
    });

    test('2 ngày khác nhau → 2 dòng', () async {
      await logRepo.recordStudy(date: DateTime(2026, 8, 2), isNewWord: false);
      await logRepo.recordStudy(date: DateTime(2026, 8, 3), isNewWord: false);
      expect(
        await logRepo.getStudyDates(),
        {'2026-08-02', '2026-08-03'},
      );
    });
  });

  group('DriftStudyStatsRepository.getTodayStats', () {
    test('rỗng → toàn 0', () async {
      final stats = await statsRepo.getTodayStats(seededAt);
      expect(stats.totalCount, 0);
      expect(stats.dueCount, 0);
      expect(stats.newCount, 0);
      expect(stats.learningCount, 0);
      expect(stats.masteredCount, 0);
      expect(stats.weakCount, 0);
    });

    test('từ chưa ôn → new + due, không learning/mastered', () async {
      final id = await insertVocab('apple');
      final stats = await statsRepo.getTodayStats(seededAt);
      expect(stats.totalCount, 1);
      expect(stats.newCount, 1);
      expect(stats.dueCount, 1); // chưa có progress → due
      expect(stats.learningCount, 0);
      expect(stats.masteredCount, 0);
      expect(stats.weakCount, 0);
      expect(id, isNonZero);
    });

    test('learning phase (learningStep != null) → learning + due nếu quá hạn', () async {
      final id = await insertVocab('banana');
      // Ôn 1 lần, đang learning step 0, quá hạn.
      await insertProgress(
        vocabId: id,
        learningStep: 0,
        nextReview: seededAt.subtract(const Duration(minutes: 1)),
        lastReview: seededAt.subtract(const Duration(days: 1)),
        reps: 1,
      );
      final stats = await statsRepo.getTodayStats(seededAt);
      expect(stats.totalCount, 1);
      expect(stats.newCount, 0); // đã ôn → không còn mới
      expect(stats.learningCount, 1);
      expect(stats.masteredCount, 0);
      expect(stats.dueCount, 1);
    });

    test('mastered (learningStep null + reps>0) → mastered, không learning', () async {
      final id = await insertVocab('cherry');
      await insertProgress(
        vocabId: id,
        learningStep: null,
        reps: 5,
        nextReview: seededAt.add(const Duration(days: 2)), // chưa đến hạn
        lastReview: seededAt.subtract(const Duration(days: 1)),
      );
      final stats = await statsRepo.getTodayStats(seededAt);
      expect(stats.masteredCount, 1);
      expect(stats.learningCount, 0);
      expect(stats.newCount, 0);
      expect(stats.dueCount, 0);
    });

    test('lapses >= 2 → weak', () async {
      final id = await insertVocab('date');
      await insertProgress(
        vocabId: id,
        lapses: 3,
        reps: 2,
        nextReview: seededAt.add(const Duration(days: 1)),
        lastReview: seededAt,
      );
      final stats = await statsRepo.getTodayStats(seededAt);
      expect(stats.weakCount, 1);
    });
  });

  group('DriftStudyStatsRepository.getActiveTopics', () {
    test('không có topic_id → rỗng', () async {
      await insertVocab('manual-word'); // catalogId null → topicId null
      expect(await statsRepo.getActiveTopics(), isEmpty);
    });

    test('join downloaded_topics_table lấy tên hiển thị, sắp theo số từ', () async {
      await insertVocab('hello', catalogId: 'greetings-001');
      await insertVocab('hi', catalogId: 'greetings-002');
      await insertVocab('travel', catalogId: 'travel-001');

      await db.into(db.downloadedTopicsTable).insert(
        DownloadedTopicsTableCompanion.insert(
          topicId: 'greetings',
          topicName: const Value('Chào hỏi'),
          downloadedVersion: 1,
          downloadedAt: seededAt,
        ),
      );
      await db.into(db.downloadedTopicsTable).insert(
        DownloadedTopicsTableCompanion.insert(
          topicId: 'travel',
          topicName: const Value('Du lịch'),
          downloadedVersion: 1,
          downloadedAt: seededAt,
        ),
      );

      final topics = await statsRepo.getActiveTopics();
      expect(topics.length, 2);
      expect(topics.first.topicId, 'greetings'); // 2 từ > 1 từ
      expect(topics.first.name, 'Chào hỏi');
      expect(topics.first.wordCount, 2);
      expect(topics.last.topicId, 'travel');
      expect(topics.last.name, 'Du lịch');
      expect(topics.last.wordCount, 1);
    });

    test('fallback tên = topicId khi downloaded_topics chưa có tên', () async {
      await insertVocab('travel', catalogId: 'travel-001');
      final topics = await statsRepo.getActiveTopics();
      expect(topics.single.name, 'travel');
      expect(topics.single.wordCount, 1);
    });
  });
}
