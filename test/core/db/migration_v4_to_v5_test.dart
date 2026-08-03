import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:voca_app/core/db/app_database.dart';

/// Migration v4 → v5: màn "Hôm nay" (task contract
/// 2026-08-03-home-dashboard-today-summary.md).
///
/// - `vocabulary_table.topic_id` (nullable) + backfill từ `catalog_id`
///   (cắt hậu tố `-<số>`; giữ NULL nếu không khớp pattern).
/// - `downloaded_topics_table.topic_name` (nullable).
/// - Bảng mới `study_log_table` (date PK, review_count, new_count, updated_at).
/// - Dữ liệu cũ phải đọc lại nguyên vẹn.
void main() {
  test(
    'migration v4 → v5: thêm topic_id/topic_name + study_log_table, '
    'backfill topic_id từ catalog_id, dữ liệu cũ nguyên vẹn',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v4.sqlite');

      // 1. Dựng schema v4 thật (chưa có topic_id/topic_name/study_log_table).
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
          catalog_id TEXT NULL,
          UNIQUE(catalog_id)
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
      raw.execute('''
        CREATE TABLE pronunciation_segments_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          position INTEGER NOT NULL,
          start_offset INTEGER NOT NULL,
          end_offset INTEGER NOT NULL,
          segment_text TEXT NOT NULL,
          ipa TEXT NOT NULL,
          stress TEXT NOT NULL,
          timing_weight REAL NOT NULL,
          UNIQUE(vocab_id, position)
        );
      ''');
      raw.execute('''
        CREATE TABLE tts_word_timing_cache_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          word_start_offset INTEGER NOT NULL,
          word_end_offset INTEGER NOT NULL,
          voice_key TEXT NOT NULL,
          speech_rate REAL NOT NULL,
          duration_ms INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(vocab_id, word_start_offset, word_end_offset, voice_key, speech_rate)
        );
      ''');

      // Data cũ: 3 từ — 2 có catalog_id dạng "topic-<số>", 1 không khớp pattern.
      raw.execute('''
        INSERT INTO vocabulary_table
        (term, definition, language, phonetic, part_of_speech, example_sentence, created_at, catalog_id)
        VALUES
        ('hello', 'xin chào', 'en', '/həˈloʊ/', 'interjection', 'Hello!', 1737000000, 'greetings-001'),
        ('travel', 'du lịch', 'en', '/ˈtræv.əl/', 'verb', 'I travel.', 1737000000, 'travel-042'),
        ('oxford', 'từ điển', 'en', '/ˈɒks.fəd/', 'noun', 'Oxford.', 1737000000, 'oxford3000');
      ''');
      raw.execute('''
        INSERT INTO progress_table
        (vocab_id, interval, ease_factor, reps, lapses, learning_step, next_review, last_review, created_at, updated_at)
        VALUES
        (1, 6, 2.6, 3, 1, NULL, 1737100000, 1737000000, 1736900000, 1737000000),
        (2, 0, 2.5, 1, 0, 0, 1737000000, NULL, 1736900000, 1737000000);
      ''');
      raw.execute('''
        INSERT INTO downloaded_topics_table (topic_id, downloaded_version, downloaded_at)
        VALUES ('travel', 2, 1737000000);
      ''');
      raw.execute('PRAGMA user_version = 4;');
      raw.close();

      // 2. Mở LẠI bằng AppDatabase hiện tại (v5) — drift chạy onUpgrade.
      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      // Dữ liệu cũ đọc nguyên vẹn.
      final vocab = await db.select(db.vocabularyTable).get();
      expect(vocab.length, 3);
      expect(vocab.map((v) => v.term).toSet(), {'hello', 'travel', 'oxford'});

      // Backfill topic_id từ catalog_id.
      final byTerm = {for (final v in vocab) v.term: v};
      expect(byTerm['hello']!.topicId, 'greetings'); // greetings-001 → greetings
      expect(byTerm['travel']!.topicId, 'travel'); // travel-042 → travel
      expect(byTerm['oxford']!.topicId, isNull); // oxford3000: không khớp pattern
      // Từ nhập tay (catalog_id NULL) → topic_id NULL.
      expect(byTerm['oxford']!.catalogId, 'oxford3000');

      // topic_name cột mới — dữ liệu cũ không có → NULL.
      final downloaded = await db.select(db.downloadedTopicsTable).getSingle();
      expect(downloaded.topicId, 'travel');
      expect(downloaded.topicName, isNull);

      // Bảng study_log mới — query rỗng không lỗi.
      expect(await db.select(db.studyLogTable).get(), isEmpty);

      // Progress cũ nguyên vẹn.
      final progress = await db.select(db.progressTable).get();
      expect(progress.length, 2);
      expect(progress.first.reps, 3);
      expect(progress.first.learningStep, isNull);
    },
  );

  test(
    'migration v4 → v5: từ nhập tay (catalog_id NULL) giữ topic_id NULL',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v4b.sqlite');
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
          catalog_id TEXT NULL,
          UNIQUE(catalog_id)
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
      raw.execute('''
        CREATE TABLE pronunciation_segments_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          position INTEGER NOT NULL,
          start_offset INTEGER NOT NULL,
          end_offset INTEGER NOT NULL,
          segment_text TEXT NOT NULL,
          ipa TEXT NOT NULL,
          stress TEXT NOT NULL,
          timing_weight REAL NOT NULL,
          UNIQUE(vocab_id, position)
        );
      ''');
      raw.execute('''
        CREATE TABLE tts_word_timing_cache_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vocab_id INTEGER NOT NULL REFERENCES vocabulary_table (id) ON DELETE CASCADE,
          word_start_offset INTEGER NOT NULL,
          word_end_offset INTEGER NOT NULL,
          voice_key TEXT NOT NULL,
          speech_rate REAL NOT NULL,
          duration_ms INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(vocab_id, word_start_offset, word_end_offset, voice_key, speech_rate)
        );
      ''');
      raw.execute('''
        INSERT INTO vocabulary_table
        (term, definition, language, phonetic, part_of_speech, example_sentence, created_at, catalog_id)
        VALUES ('manual', 'nhập tay', 'en', '/ˈmæn.ju.əl/', NULL, 'Manual.', 1737000000, NULL);
      ''');
      raw.execute('PRAGMA user_version = 4;');
      raw.close();

      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      final v = await db.select(db.vocabularyTable).getSingle();
      expect(v.catalogId, isNull);
      expect(v.topicId, isNull);
      expect(await db.select(db.studyLogTable).get(), isEmpty);
    },
  );
}
