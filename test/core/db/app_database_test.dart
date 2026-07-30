import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';

/// Schema hiện đang ở version 1 (khởi tạo lần đầu) — chưa có version cũ nào
/// để test "migrate từ version cũ, verify dữ liệu nguyên vẹn" như quy tắc
/// migration trong PLAN-PHASE-1-2.md. Test ở đây verify việc DUY NHẤT có ý
/// nghĩa ở version 1: `onCreate` tạo đúng bảng, đọc/ghi round-trip đúng, và
/// ràng buộc `uniqueKeys` trên `vocabId` được enforce. Test migrate
/// version→version thật sẽ viết khi `schemaVersion` tăng lên 2.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'onCreate tạo đủ bảng — insert/đọc vocabulary + progress round-trip',
    () async {
      final vocabId = await db
          .into(db.vocabularyTable)
          .insert(
            VocabularyTableCompanion.insert(
              term: 'ephemeral',
              definition: 'phù du, chóng tàn',
              language: 'en',
              phonetic: '/ɪˈfem.ər.əl/',
              partOfSpeech: 'adj',
              exampleSentence: 'Fame is ephemeral.',
              createdAt: DateTime(2026, 1, 1),
            ),
          );

      final now = DateTime(2026, 1, 15);
      await db
          .into(db.progressTable)
          .insert(
            ProgressTableCompanion.insert(
              vocabId: vocabId,
              interval: 1,
              easeFactor: 2.5,
              reps: 1,
              lapses: 0,
              nextReview: now.add(const Duration(days: 1)),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final vocab = await (db.select(
        db.vocabularyTable,
      )..where((t) => t.id.equals(vocabId))).getSingle();
      expect(vocab.term, 'ephemeral');
      expect(vocab.phonetic, '/ɪˈfem.ər.əl/');

      final progress = await (db.select(
        db.progressTable,
      )..where((t) => t.vocabId.equals(vocabId))).getSingle();
      expect(progress.interval, 1);
      expect(progress.easeFactor, 2.5);
      expect(progress.lastReview, isNull);
    },
  );

  test('mỗi vocab chỉ có 1 progress — vi phạm uniqueKeys bị chặn', () async {
    final vocabId = await db
        .into(db.vocabularyTable)
        .insert(
          VocabularyTableCompanion.insert(
            term: 'test',
            definition: 'test',
            language: 'en',
            phonetic: '/test/',
            partOfSpeech: 'noun',
            exampleSentence: 'A test.',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    final companion = ProgressTableCompanion.insert(
      vocabId: vocabId,
      interval: 1,
      easeFactor: 2.5,
      reps: 1,
      lapses: 0,
      nextReview: DateTime(2026, 1, 16),
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
    );

    await db.into(db.progressTable).insert(companion);

    expect(
      () => db.into(db.progressTable).insert(companion),
      throwsException,
    );
  });
}
