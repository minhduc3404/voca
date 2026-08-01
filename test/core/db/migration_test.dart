import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:voca_app/core/db/app_database.dart';

/// Migration test THẬT đầu tiên (v1 → v2, ADR-011) — trước đây schema chỉ
/// ở v1 nên "migration test" chỉ test được `onCreate`. Giờ dựng schema v1
/// bằng raw SQL (khớp `core/db/tables.dart` TRƯỚC khi có `learningStep`),
/// insert dữ liệu, rồi mở lại bằng `AppDatabase` (v2) để drift tự chạy
/// `onUpgrade`.
void main() {
  test(
    'migration v1 → v2: thêm learningStep, dữ liệu cũ đọc được nguyên vẹn',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v1.sqlite');

      // 1. Dựng schema v1 thật (chưa có learning_step) bằng raw SQL.
      final raw = sqlite3.sqlite3.open(dbFile.path);
      raw.execute('''
        CREATE TABLE vocabulary_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          term TEXT NOT NULL,
          definition TEXT NOT NULL,
          language TEXT NOT NULL,
          phonetic TEXT NOT NULL,
          part_of_speech TEXT NULL,
          example_sentence TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''');
      raw.execute('''
        CREATE TABLE progress_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          interval INTEGER NOT NULL,
          ease_factor REAL NOT NULL,
          reps INTEGER NOT NULL,
          lapses INTEGER NOT NULL,
          next_review INTEGER NOT NULL,
          last_review INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(vocab_id)
        );
      ''');
      raw.execute(
        "INSERT INTO vocabulary_table "
        "(term, definition, language, phonetic, part_of_speech, example_sentence, created_at) "
        "VALUES ('legacy', 'từ cũ', 'en', '/ˈleɡ.ə.si/', 'noun', 'A legacy word.', 1737000000);",
      );
      raw.execute(
        "INSERT INTO progress_table "
        "(vocab_id, interval, ease_factor, reps, lapses, next_review, last_review, created_at, updated_at) "
        "VALUES (1, 6, 2.6, 3, 1, 1737100000, 1737000000, 1736900000, 1737000000);",
      );
      raw.execute('PRAGMA user_version = 1;');
      raw.close();

      // 2. Mở LẠI cùng file bằng AppDatabase hiện tại (v2, schemaVersion =
      //    2) — drift thấy user_version = 1 < 2 nên tự chạy onUpgrade.
      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      final vocab = await db.select(db.vocabularyTable).getSingle();
      expect(vocab.term, 'legacy');
      expect(vocab.definition, 'từ cũ');
      expect(vocab.partOfSpeech, 'noun');

      final progress = await db.select(db.progressTable).getSingle();
      expect(progress.interval, 6);
      expect(progress.easeFactor, 2.6);
      expect(progress.reps, 3);
      expect(progress.lapses, 1);
      // Dữ liệu v1 không có khái niệm learning phase → migrate lên coi như
      // đã graduate (learningStep = null), đúng ý nghĩa cũ của các dòng này.
      expect(progress.learningStep, isNull);
    },
  );

  test(
    'migration v2 → v3: thêm catalogId + downloadedTopicsTable, dữ liệu cũ đọc được nguyên vẹn',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v2.sqlite');

      // 1. Dựng schema v2 thật (có learning_step, CHƯA có catalog_id/
      //    downloaded_topics_table) bằng raw SQL.
      final raw = sqlite3.sqlite3.open(dbFile.path);
      raw.execute('''
        CREATE TABLE vocabulary_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          term TEXT NOT NULL,
          definition TEXT NOT NULL,
          language TEXT NOT NULL,
          phonetic TEXT NOT NULL,
          part_of_speech TEXT NULL,
          example_sentence TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''');
      raw.execute('''
        CREATE TABLE progress_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          interval INTEGER NOT NULL,
          ease_factor REAL NOT NULL,
          reps INTEGER NOT NULL,
          lapses INTEGER NOT NULL,
          learning_step INTEGER NULL,
          next_review INTEGER NOT NULL,
          last_review INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(vocab_id)
        );
      ''');
      raw.execute(
        "INSERT INTO vocabulary_table "
        "(term, definition, language, phonetic, part_of_speech, example_sentence, created_at) "
        "VALUES ('legacy', 'từ cũ', 'en', '/ˈleɡ.ə.si/', 'noun', 'A legacy word.', 1737000000);",
      );
      raw.execute('PRAGMA user_version = 2;');
      raw.close();

      // 2. Mở LẠI cùng file bằng AppDatabase hiện tại (v3) — drift thấy
      //    user_version = 2 < 3 nên tự chạy onUpgrade.
      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      final vocab = await db.select(db.vocabularyTable).getSingle();
      expect(vocab.term, 'legacy');
      // Dữ liệu cũ không đến từ catalog nào → catalogId tự NULL.
      expect(vocab.catalogId, isNull);

      // Bảng mới đã tạo, query rỗng không lỗi.
      final downloaded = await db.select(db.downloadedTopicsTable).get();
      expect(downloaded, isEmpty);
    },
  );

  test(
    'migration v3 → v4: tạo segment và TTS timing cache, giữ vocabulary',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v3.sqlite');
      final raw = sqlite3.sqlite3.open(dbFile.path);
      raw.execute('''
      CREATE TABLE vocabulary_table (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        term TEXT NOT NULL,
        definition TEXT NOT NULL,
        language TEXT NOT NULL,
        phonetic TEXT NOT NULL,
        part_of_speech TEXT NULL,
        example_sentence TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        catalog_id TEXT NULL
      );
    ''');
      raw.execute('''
      CREATE TABLE progress_table (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
        interval INTEGER NOT NULL,
        ease_factor REAL NOT NULL,
        reps INTEGER NOT NULL,
        lapses INTEGER NOT NULL,
        learning_step INTEGER NULL,
        next_review INTEGER NOT NULL,
        last_review INTEGER NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(vocab_id)
      );
    ''');
      raw.execute('''
      CREATE TABLE downloaded_topics_table (
        topic_id TEXT NOT NULL PRIMARY KEY,
        downloaded_version INTEGER NOT NULL,
        downloaded_at INTEGER NOT NULL
      );
    ''');
      raw.execute(
        "INSERT INTO vocabulary_table "
        "(term, definition, language, phonetic, example_sentence, created_at) "
        "VALUES ('legacy', 'từ cũ', 'en', '/leɡ.ə.si/', 'A legacy word.', 1737000000);",
      );
      raw.execute('PRAGMA user_version = 3;');
      raw.close();

      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      expect((await db.select(db.vocabularyTable).getSingle()).term, 'legacy');
      expect(await db.select(db.pronunciationSegmentsTable).get(), isEmpty);
      expect(await db.select(db.ttsWordTimingCacheTable).get(), isEmpty);
    },
  );
}
