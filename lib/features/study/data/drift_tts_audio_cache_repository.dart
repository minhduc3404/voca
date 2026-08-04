import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/db/app_database.dart';
import '../domain/tts_audio_cache_repository.dart';
import '../domain/tts_service.dart';

/// Cache audio TTS bền vững: bytes WAV lưu file rời trên disk, Drift chỉ
/// giữ metadata index (không BLOB audio vào SQLite — tránh phình DB/WAL).
/// Ghi file trước, insert/update row sau — không bao giờ có row trỏ tới
/// file chưa tồn tại; đọc giữa chừng chỉ thấy cache miss, không lỗi.
class DriftTtsAudioCacheRepository implements TtsAudioCacheRepository {
  DriftTtsAudioCacheRepository(this._db, {Directory? baseDir})
    : _baseDir = baseDir;

  final AppDatabase _db;

  /// Thư mục gốc chứa cache (thường là app support dir). Inject để test.
  final Directory? _baseDir;

  Future<Directory> get _cacheDir async {
    final base = _baseDir ?? await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts_audio_cache'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  @override
  Future<TtsAudioCacheEntry?> get(String cacheKey) async {
    final row = await (_db.select(
      _db.ttsAudioCacheTable,
    )..where((t) => t.cacheKey.equals(cacheKey))).getSingleOrNull();
    if (row == null) return null;

    final file = File(row.filePath);
    if (!file.existsSync()) {
      // Row mồ côi (file mất ngoài ý muốn) — dọn để lần sau synth lại sạch,
      // không giữ row trỏ tới file không tồn tại.
      await (_db.delete(
        _db.ttsAudioCacheTable,
      )..where((t) => t.id.equals(row.id))).go();
      return null;
    }

    unawaited(_touch(row.id));
    return TtsAudioCacheEntry(
      filePath: row.filePath,
      sampleRate: row.sampleRate,
      wordRanges: _decodeRanges(row.wordRangesJson),
    );
  }

  @override
  Future<TtsAudioCacheEntry> put(
    String cacheKey, {
    required List<int> wavBytes,
    required int sampleRate,
    required List<TtsWordRange> wordRanges,
  }) async {
    final dir = await _cacheDir;
    final fileName = '${sha1.convert(utf8.encode(cacheKey))}.wav';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(wavBytes, flush: true);

    final now = DateTime.now();
    // `insertOnConflictUpdate` chỉ nhận diện xung đột trên primary key
    // (`id`, auto-increment — luôn khác ở lần ghi mới); conflict thật ta cần
    // xử lý là `cacheKey` (unique). `insertOrReplace` khớp MỌI unique
    // constraint, đúng ý nghĩa "put = ghi đè entry cho key này".
    await _db
        .into(_db.ttsAudioCacheTable)
        .insert(
          TtsAudioCacheTableCompanion.insert(
            cacheKey: cacheKey,
            filePath: file.path,
            sampleRate: sampleRate,
            wordRangesJson: _encodeRanges(wordRanges),
            byteSize: wavBytes.length,
            createdAt: now,
            lastUsedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    return TtsAudioCacheEntry(
      filePath: file.path,
      sampleRate: sampleRate,
      wordRanges: wordRanges,
    );
  }

  Future<void> _touch(int id) {
    return (_db.update(
      _db.ttsAudioCacheTable,
    )..where((t) => t.id.equals(id))).write(
      TtsAudioCacheTableCompanion(lastUsedAt: Value(DateTime.now())),
    );
  }

  static String _encodeRanges(List<TtsWordRange> ranges) {
    return jsonEncode([
      for (final range in ranges)
        {'text': range.text, 'start': range.start, 'end': range.end},
    ]);
  }

  static List<TtsWordRange> _decodeRanges(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return [
      for (final item in list.cast<Map<String, dynamic>>())
        TtsWordRange(
          text: item['text'] as String,
          start: item['start'] as int,
          end: item['end'] as int,
        ),
    ];
  }
}
