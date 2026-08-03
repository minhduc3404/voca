import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/data/tts/tts_model_manager.dart';
import 'package:voca_app/features/study/data/tts/tts_models.dart';

/// Fake manager: override `downloadArchive` để không đụng Firebase thật.
class _FakeTtsModelManager extends TtsModelManager {
  _FakeTtsModelManager({
    required super.baseDir,
    required this.archiveBytes,
    this.failOnce = false,
  });

  final Uint8List archiveBytes;
  bool failOnce;
  int downloadCount = 0;
  int? lastProgressBytes;

  @override
  Future<void> downloadArchive(
    TtsModelSpec spec,
    File target, {
    void Function(int downloadedBytes, int totalBytes)? progress,
  }) async {
    downloadCount++;
    if (failOnce && downloadCount == 1) {
      throw StateError('network down');
    }
    target.writeAsBytesSync(archiveBytes);
    progress?.call(archiveBytes.length, archiveBytes.length);
  }
}

void main() {
  late Directory tmpDir;
  late TtsModelSpec spec;

  const archivePath = 'vits-vctk';
  final archiveBytes = Uint8List.fromList(
    // Build tar.bz2: vits-vctk/tokens.txt + vits-vctk/vits-vctk.int8.onnx
    _buildTarBz2({
      '$archivePath/tokens.txt': _utf8Bytes('_ 0\n'),
      '$archivePath/vits-vctk.int8.onnx': _utf8Bytes('fake-onnx-bytes'),
    }),
  );

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('tts_model_test');
    spec = ttsModels.first;
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  test('tải model mới: download + extract + marker', () async {
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
    );
    final result = await manager.ensureModel(spec);

    expect(manager.downloadCount, 1);
    expect(result.modelDir.path, '${tmpDir.path}/${spec.id}');
    // Files đã giải nén (bỏ prefix archivePath/)
    expect(
      File('${result.modelDir.path}/${spec.modelRelPath}').existsSync(),
      isTrue,
    );
    expect(
      File('${result.modelDir.path}/${spec.tokensRelPath}').existsSync(),
      isTrue,
    );
    // Marker đánh dấu hoàn tất
    expect(
      File('${result.modelDir.path}/.complete').existsSync(),
      isTrue,
    );
    // File tạm .download đã được dọn
    expect(
      File('${tmpDir.path}/.${spec.id}.tar.bz2.download').existsSync(),
      isFalse,
    );
  });

  test('model đã có trên disk: không tải lại (cache)', () async {
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
    );
    await manager.ensureModel(spec);
    final result2 = await manager.ensureModel(spec);

    expect(manager.downloadCount, 1);
    expect(result2.modelDir.path, '${tmpDir.path}/${spec.id}');
  });

  test('lỗi mạng lần đầu → retry thành công (file tạm không để lại)', () async {
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
      failOnce: true,
    );
    await expectLater(manager.ensureModel(spec), throwsA(isA<StateError>()));
    // Retry
    final result = await manager.ensureModel(spec);

    expect(manager.downloadCount, 2);
    expect(
      File('${result.modelDir.path}/${spec.modelRelPath}').existsSync(),
      isTrue,
    );
    expect(
      File('${tmpDir.path}/.${spec.id}.tar.bz2.download').existsSync(),
      isFalse,
    );
  });

  test('checksum sai → throw, không đánh dấu complete', () async {
    final badSpec = TtsModelSpec(
      id: 'vits-vctk-int8',
      displayName: 'VCTK (English, 109 voices)',
      language: 'en',
      firebasePath: 'tts/vits-vctk.tar.bz2',
      archivePath: 'vits-vctk',
      modelRelPath: 'vits-vctk.int8.onnx',
      tokensRelPath: 'tokens.txt',
      lexiconRelPath: 'lexicon.txt',
      sha256: '0' * 64, // sai checksum
      license: 'x',
    );
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
    );
    await expectLater(
      manager.ensureModel(badSpec),
      throwsA(isA<StateError>()),
    );
    expect(
      File('${tmpDir.path}/${badSpec.id}/.complete').existsSync(),
      isFalse,
    );
  });

  test('progress callback nhận dung lượng', () async {
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
    );
    int? reported;
    await manager.ensureModel(spec, progress: (down, total) {
      reported = down;
    });
    expect(reported, archiveBytes.length);
  });

  test('removeModel xoá toàn bộ thư mục model', () async {
    final manager = _FakeTtsModelManager(
      baseDir: tmpDir,
      archiveBytes: archiveBytes,
    );
    await manager.ensureModel(spec);
    await manager.removeModel(spec);
    expect(Directory('${tmpDir.path}/${spec.id}').existsSync(), isFalse);
  });
}

Uint8List _utf8Bytes(String s) => Uint8List.fromList(s.codeUnits);

/// Build tar.bz2 archive từ map path → bytes (pure-Dart, giống format
/// tts-models của sherpa-onnx).
Uint8List _buildTarBz2(Map<String, Uint8List> files) {
  final archive = Archive();
  for (final entry in files.entries) {
    archive.addFile(
      ArchiveFile(entry.key, entry.value.length, entry.value),
    );
  }
  final tarBytes = TarEncoder().encode(archive);
  final bz2 = BZip2Encoder().encode(tarBytes);
  return Uint8List.fromList(bz2);
}
