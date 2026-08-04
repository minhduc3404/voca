import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tts_models.dart';

/// Trạng thái tải model — data layer chỉ expose model + lỗi, không đụng UI.
class TtsModelLoadResult {
  const TtsModelLoadResult({required this.spec, required this.modelDir});

  final TtsModelSpec spec;

  /// Thư mục chứa model đã giải nén (model, tokens, lexicon...).
  final Directory modelDir;
}

/// Quản lý model TTS trên disk: tải tar.bz2 qua HTTP (GitHub Releases —
/// xem `tts_models.dart`) khi cần, verify checksum, giải nén (pure-Dart
/// `archive`, không phụ thuộc binary `tar` — quan trọng trên Android), và
/// trả về đường dẫn cho `SherpaOnnxTtsService` khởi tạo engine.
///
/// Tất cả logic I/O nằm trong `data/` (AGENTS.md §2); application/domain
/// không biết HTTP hay filesystem.
class TtsModelManager {
  TtsModelManager({HttpClient? httpClient, Directory? baseDir})
    : _httpClient = httpClient,
      _baseDir = baseDir;

  /// Lazy: chỉ khởi tạo khi thật sự tải (test override `downloadArchive`
  /// không cần client thật).
  final HttpClient? _httpClient;

  /// Thư mục gốc chứa các model (thường là app support dir). Inject để test.
  final Directory? _baseDir;

  /// Thư mục gốc chứa các model.
  Future<Directory> get _root async {
    final base = _baseDir;
    if (base != null) return base;
    final appSupport = await getApplicationSupportDirectory();
    return Directory(p.join(appSupport.path, 'tts_models'));
  }

  /// Trả về model đã sẵn sàng (đã giải nén), tải + verify + extract nếu chưa.
  ///
  /// [progress] nhận (downloadedBytes, totalBytes) — dùng cho UI tải model
  /// (Phase B settings). Phase A có thể bỏ qua.
  Future<TtsModelLoadResult> ensureModel(
    TtsModelSpec spec, {
    void Function(int downloadedBytes, int totalBytes)? progress,
  }) async {
    final root = await _root;
    final modelDir = Directory(p.join(root.path, spec.id));
    final marker = File(p.join(modelDir.path, '.complete'));
    if (marker.existsSync()) {
      return TtsModelLoadResult(spec: spec, modelDir: modelDir);
    }

    // Tải archive về file tạm, verify + giải nén, rồi đánh dấu hoàn tất.
    final tmp = File(p.join(root.path, '.${spec.id}.tar.bz2.download'));
    await root.create(recursive: true);
    try {
      await _download(spec, tmp, progress: progress);
      if (spec.sha256.isNotEmpty) {
        _verifyChecksum(tmp, spec);
      }
      _extract(tmp, modelDir, spec);
      marker.writeAsStringSync('ok');
      return TtsModelLoadResult(spec: spec, modelDir: modelDir);
    } finally {
      if (tmp.existsSync()) {
        tmp.deleteSync();
      }
    }
  }

  /// Xoá model khỏi disk (giải phóng dung lượng khi user đổi model).
  Future<void> removeModel(TtsModelSpec spec) async {
    final root = await _root;
    final dir = Directory(p.join(root.path, spec.id));
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  /// Tải file từ [TtsModelSpec.downloadUrl] về [target] qua HTTP GET. Tách
  /// thành method để test override mà không cần gọi mạng thật.
  @visibleForTesting
  Future<void> downloadArchive(
    TtsModelSpec spec,
    File target, {
    void Function(int downloadedBytes, int totalBytes)? progress,
  }) async {
    final client = _httpClient ?? HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(spec.downloadUrl));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw StateError(
          'Tải model "${spec.id}" thất bại: HTTP ${response.statusCode}.',
        );
      }
      final total = response.contentLength;
      var downloaded = 0;
      final sink = target.openWrite();
      try {
        await response.forEach((chunk) {
          sink.add(chunk);
          downloaded += chunk.length;
          progress?.call(downloaded, total);
        });
      } finally {
        await sink.close();
      }
    } finally {
      if (_httpClient == null) {
        client.close(force: true);
      }
    }
  }

  Future<void> _download(
    TtsModelSpec spec,
    File target, {
    void Function(int downloadedBytes, int totalBytes)? progress,
  }) {
    return downloadArchive(spec, target, progress: progress);
  }

  void _verifyChecksum(File archive, TtsModelSpec spec) {
    final bytes = archive.readAsBytesSync();
    final digest = sha256.convert(bytes).toString();
    if (digest != spec.sha256) {
      throw StateError(
        'Checksum model "${spec.id}" không khớp (expected ${spec.sha256}, got $digest).',
      );
    }
  }

  /// Giải nén tar.bz2 vào [destDir] bằng pure-Dart `archive`. Bỏ path prefix
  /// theo [spec.archivePath] (thư mục gốc trong tarball).
  void _extract(File archive, Directory destDir, TtsModelSpec spec) {
    if (destDir.existsSync()) {
      destDir.deleteSync(recursive: true);
    }
    destDir.createSync(recursive: true);

    final bytes = archive.readAsBytesSync();
    final bz2 = BZip2Decoder().decodeBytes(bytes);
    final archiveObj = TarDecoder().decodeBytes(bz2);
    extractArchiveToDiskSync(archiveObj, destDir.path);

    // Di chuyển nội dung từ <archivePath>/ lên destDir nếu có prefix.
    final inner = Directory(p.join(destDir.path, spec.archivePath));
    if (inner.existsSync()) {
      for (final entry in inner.listSync()) {
        final dest = p.join(destDir.path, p.basename(entry.path));
        if (entry is Directory) {
          entry.renameSync(dest);
        } else {
          File(entry.path).renameSync(dest);
        }
      }
      inner.deleteSync(recursive: true);
    }
  }
}
