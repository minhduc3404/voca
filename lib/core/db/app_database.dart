import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    VocabularyTable,
    ProgressTable,
    DownloadedTopicsTable,
    PronunciationSegmentsTable,
    TtsWordTimingCacheTable,
    StudyLogTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Dùng cho test — inject `NativeDatabase.memory()` hoặc executor khác
  /// thay vì mở file DB thật qua `drift_flutter`. Không seed demo data để
  /// giữ test hermetic.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // ADR-011: thêm learning steps. Dữ liệu v1 không có khái niệm
        // learning phase → migrate lên coi như đã graduate — cột mới
        // nullable, không set default nên tự NULL cho dòng cũ, đúng ý
        // nghĩa "learningStep = null = review phase".
        await migrator.addColumn(progressTable, progressTable.learningStep);
      }
      if (from < 3) {
        // Catalog từ vựng theo chủ đề (Firebase Storage) — xem task
        // contract 2026-07-31-vocabulary-catalog-firebase.md. Dữ liệu cũ
        // không đến từ catalog nào → catalogId tự NULL, đúng ý nghĩa.
        //
        // SQLite KHÔNG cho `ALTER TABLE ... ADD COLUMN ... UNIQUE` — phải
        // thêm cột trơn rồi tạo unique index riêng (NULL không tính trùng
        // trong unique index, đúng ý "chưa có catalogId").
        await migrator.database.customStatement(
          'ALTER TABLE vocabulary_table ADD COLUMN catalog_id TEXT NULL;',
        );
        await migrator.database.customStatement(
          'CREATE UNIQUE INDEX vocabulary_table_catalog_id_idx '
          'ON vocabulary_table (catalog_id);',
        );
        await migrator.createTable(downloadedTopicsTable);
      }
      if (from < 4) {
        await migrator.createTable(pronunciationSegmentsTable);
        await migrator.createTable(ttsWordTimingCacheTable);
      }
      if (from < 5) {
        // Màn "Hôm nay": chủ đề đang học + streak.
        // - vocabulary_table.topic_id: nullable, backfill từ catalog_id
        //   (cắt hậu tố `-<số>`). Từ nhập tay không có catalog_id → NULL.
        // - downloaded_topics_table.topic_name: nullable, lưu tên hiển thị
        //   để hiển thị offline.
        // - study_log_table: mới, ghi nhật ký ôn theo ngày cho streak.
        await migrator.addColumn(vocabularyTable, vocabularyTable.topicId);
        await migrator.addColumn(
          downloadedTopicsTable,
          downloadedTopicsTable.topicName,
        );
        await migrator.createTable(studyLogTable);

        // Backfill topic_id từ catalog_id bằng Dart (dễ test + đúng với mọi
        // catalog id pattern). Rule: cắt hậu tố `-<số>` (vd `travel-001` →
        // `travel`); giữ nguyên nếu không khớp pattern (vd `oxford3000`).
        final rows = await migrator.database
            .customSelect(
              'SELECT id, catalog_id FROM vocabulary_table '
              'WHERE catalog_id IS NOT NULL AND topic_id IS NULL',
            )
            .get();
        final updates = <(int, String)>[];
        for (final row in rows) {
          final catalogId = row.readNullable<String>('catalog_id');
          final topicId = catalogId == null
              ? null
              : _topicIdFromCatalogId(catalogId);
          if (topicId != null) updates.add((row.read<int>('id'), topicId));
        }
        for (final (id, topicId) in updates) {
          await migrator.database.customStatement(
            'UPDATE vocabulary_table SET topic_id = ? WHERE id = ?',
            [topicId, id],
          );
        }
      }
    },
  );
}

/// `"travel-001"` → `"travel"`, `"oxford3000"` → `null` (không có hậu tố số
/// tách bằng `-`). Rule dùng chung cho backfill v4→v5 và cho import mới.
String? _topicIdFromCatalogId(String catalogId) {
  final dashIndex = catalogId.lastIndexOf('-');
  if (dashIndex <= 0 || dashIndex == catalogId.length - 1) return null;
  final suffix = catalogId.substring(dashIndex + 1);
  if (suffix.isEmpty || int.tryParse(suffix) == null) return null;
  return catalogId.substring(0, dashIndex);
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
