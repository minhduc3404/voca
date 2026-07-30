import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/core/db/seed_data.dart';

void main() {
  test('seedInitialVocabulary chèn đủ 8 từ, term không trùng', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await seedInitialVocabulary(db);

    final rows = await db.select(db.vocabularyTable).get();
    expect(rows.length, 8);
    expect(rows.map((r) => r.term).toSet().length, 8);
    expect(rows.every((r) => r.phonetic.isNotEmpty), isTrue);
    expect(rows.every((r) => r.exampleSentence.isNotEmpty), isTrue);
  });

  test('AppDatabase.forTesting KHÔNG tự seed — giữ test hermetic', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final rows = await db.select(db.vocabularyTable).get();
    expect(rows, isEmpty);
  });
}
