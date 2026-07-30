import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [VocabularyTable, ProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Dùng cho test — inject `NativeDatabase.memory()` hoặc executor khác
  /// thay vì mở file DB thật qua `drift_flutter`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    // onUpgrade sẽ thêm khi schemaVersion tăng — xem "Migration rules"
    // trong PLAN-PHASE-1-2.md. Chưa có version cũ nào để migrate từ đó.
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'voca',
    // Ignored trên native, bắt buộc phải truyền khi compile ra web (drift
    // dùng SQLite qua WASM + Web Worker thay vì file, không có path_provider).
    // sqlite3.wasm + drift_worker.js copy từ package drift, đặt trong web/.
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
