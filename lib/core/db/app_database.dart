import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [VocabularyTable, ProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : _seedDemoData = true, super(_openConnection());

  /// Dùng cho test — inject `NativeDatabase.memory()` hoặc executor khác
  /// thay vì mở file DB thật qua `drift_flutter`. Không seed demo data để
  /// giữ test hermetic.
  AppDatabase.forTesting(super.executor) : _seedDemoData = false;

  final bool _seedDemoData;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      // TẠM THỜI — seed data mẫu để app có nội dung ngay từ lần cài đầu
      // tiên. Sẽ bỏ khi có feature nhập từ vựng thật (PLAN.md Phase 5).
      if (_seedDemoData) {
        await seedInitialVocabulary(this);
      }
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // ADR-011: thêm learning steps. Dữ liệu v1 không có khái niệm
        // learning phase → migrate lên coi như đã graduate — cột mới
        // nullable, không set default nên tự NULL cho dòng cũ, đúng ý
        // nghĩa "learningStep = null = review phase".
        await migrator.addColumn(progressTable, progressTable.learningStep);
      }
    },
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
