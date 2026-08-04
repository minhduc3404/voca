import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:voca_app/core/db/app_database.dart';

/// Migration v5 → v6: cache audio TTS bền vững trên disk (task contract
/// "TTS Audio Disk Cache" increment 1).
///
/// - Bảng mới `tts_audio_cache_table` (cache_key unique, file_path,
///   sample_rate, word_ranges_json, byte_size, created_at, last_used_at).
/// - Không đụng cột nào của bảng cũ — dữ liệu v5 phải đọc lại nguyên vẹn.
void main() {
  test(
    'migration v5 → v6: thêm tts_audio_cache_table, dữ liệu cũ nguyên vẹn',
    () async {
      final dir = await Directory.systemTemp.createTemp('voca_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final dbFile = File('${dir.path}/voca_v5.sqlite');

      // 1. Dựng schema v5 thật (chưa có tts_audio_cache_table).
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
          topic_id TEXT NULL,
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
          downloaded_at INTEGER NOT NULL,
          topic_name TEXT NULL
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
        CREATE TABLE study_log_table (
          date TEXT NOT NULL PRIMARY KEY,
          review_count INTEGER NOT NULL,
          new_count INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

      raw.execute('''
        INSERT INTO vocabulary_table
        (term, definition, language, phonetic, part_of_speech, example_sentence, created_at, catalog_id, topic_id)
        VALUES ('reservation', 'đặt chỗ', 'en', '/ˌrez.ɚˈveɪ.ʃən/', 'noun', 'I made a reservation.', 1737000000, 'travel-001', 'travel');
      ''');
      raw.execute('''
        INSERT INTO study_log_table (date, review_count, new_count, updated_at)
        VALUES ('2026-08-01', 3, 1, 1737000000);
      ''');
      raw.execute('PRAGMA user_version = 5;');
      raw.close();

      // 2. Mở LẠI bằng AppDatabase hiện tại (v6) — drift tự chạy onUpgrade.
      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);

      // Dữ liệu cũ đọc nguyên vẹn.
      final vocab = await db.select(db.vocabularyTable).getSingle();
      expect(vocab.term, 'reservation');
      expect(vocab.topicId, 'travel');
      final studyLog = await db.select(db.studyLogTable).getSingle();
      expect(studyLog.reviewCount, 3);

      // Bảng mới rỗng nhưng query được, và ghi/đọc round-trip đúng.
      expect(await db.select(db.ttsAudioCacheTable).get(), isEmpty);

      final now = DateTime(2026, 8, 4);
      await db
          .into(db.ttsAudioCacheTable)
          .insert(
            TtsAudioCacheTableCompanion.insert(
              cacheKey: 'vits-vctk-int8|<default>|1.0|reservation',
              filePath: '/tmp/reservation.wav',
              sampleRate: 22050,
              wordRangesJson: '[]',
              byteSize: 4,
              createdAt: now,
              lastUsedAt: now,
            ),
          );
      final cached = await db.select(db.ttsAudioCacheTable).getSingle();
      expect(cached.cacheKey, 'vits-vctk-int8|<default>|1.0|reservation');
      expect(cached.filePath, '/tmp/reservation.wav');
    },
  );
}
