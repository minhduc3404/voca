import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/features/study/data/drift_tts_audio_cache_repository.dart';
import 'package:voca_app/features/study/domain/tts_service.dart';

void main() {
  late AppDatabase db;
  late Directory tmpDir;
  late DriftTtsAudioCacheRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tmpDir = Directory.systemTemp.createTempSync('tts_audio_cache_test');
    repository = DriftTtsAudioCacheRepository(db, baseDir: tmpDir);
  });

  tearDown(() async {
    await db.close();
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  test('miss khi chưa cache', () async {
    expect(await repository.get('vits-vctk-int8|<default>|1.0|reservation'), isNull);
  });

  test('put rồi get: đọc lại đúng file trên disk, sống qua instance mới (giả lập restart app)', () async {
    const key = 'vits-vctk-int8|<default>|1.0|reservation';
    final entry = await repository.put(
      key,
      wavBytes: const [1, 2, 3, 4],
      sampleRate: 22050,
      wordRanges: const [
        TtsWordRange(text: 'reservation', start: 0, end: 11),
      ],
    );

    expect(File(entry.filePath).existsSync(), isTrue);
    expect(File(entry.filePath).readAsBytesSync(), [1, 2, 3, 4]);
    expect(entry.sampleRate, 22050);
    expect(entry.wordRanges.single.text, 'reservation');

    // Repository mới cùng DB + baseDir (mô phỏng app khởi động lại, engine
    // TTS đã dispose nhưng disk + Drift file còn nguyên).
    final reopened = DriftTtsAudioCacheRepository(db, baseDir: tmpDir);
    final fetched = await reopened.get(key);
    expect(fetched, isNotNull);
    expect(fetched!.filePath, entry.filePath);
    expect(fetched.sampleRate, 22050);
    expect(fetched.wordRanges.single.end, 11);
  });

  test('put cùng key ghi đè (đổi text/speed → key khác, không đụng entry cũ)', () async {
    const key = 'vits-vctk-int8|<default>|1.0|hello';
    await repository.put(
      key,
      wavBytes: const [1, 1],
      sampleRate: 22050,
      wordRanges: const [],
    );
    final second = await repository.put(
      key,
      wavBytes: const [2, 2, 2],
      sampleRate: 22050,
      wordRanges: const [],
    );

    final fetched = await repository.get(key);
    expect(fetched!.filePath, second.filePath);
    expect(File(fetched.filePath).readAsBytesSync(), [2, 2, 2]);
  });

  test('file bị xoá ngoài ý muốn: get coi như miss và dọn row mồ côi', () async {
    const key = 'vits-vctk-int8|<default>|1.0|orphan';
    final entry = await repository.put(
      key,
      wavBytes: const [9, 9],
      sampleRate: 22050,
      wordRanges: const [],
    );
    File(entry.filePath).deleteSync();

    expect(await repository.get(key), isNull);

    // Row đã bị dọn — put lại tạo entry mới sạch, không lỗi unique constraint.
    final rewritten = await repository.put(
      key,
      wavBytes: const [7],
      sampleRate: 22050,
      wordRanges: const [],
    );
    expect(File(rewritten.filePath).readAsBytesSync(), [7]);
  });

  test('cache key khác nhau (model/voice/speed/text) không đụng nhau', () async {
    await repository.put(
      'vits-vctk-int8|<default>|1.0|hello',
      wavBytes: const [1],
      sampleRate: 22050,
      wordRanges: const [],
    );
    await repository.put(
      'vits-vctk-int8|<default>|1.5|hello',
      wavBytes: const [2],
      sampleRate: 22050,
      wordRanges: const [],
    );

    final slow = await repository.get('vits-vctk-int8|<default>|1.0|hello');
    final fast = await repository.get('vits-vctk-int8|<default>|1.5|hello');
    expect(File(slow!.filePath).readAsBytesSync(), [1]);
    expect(File(fast!.filePath).readAsBytesSync(), [2]);
  });
}
