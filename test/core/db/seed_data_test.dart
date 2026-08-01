import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';

void main() {
  test('database mới tạo không seed vocabulary hardcode', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final rows = await db.select(db.vocabularyTable).get();
    expect(rows, isEmpty);
  });
}
