/// Catalog các model TTS offline (sherpa-onnx) mà app hỗ trợ.
///
/// Giá trị hằng, không chứa logic. Model được tải theo yêu cầu từ
/// Firebase Storage (xem `tts_model_manager.dart`); app không bundle model
/// vào binary.
///
/// Mô hình phân phối: mỗi model là một file `tar.bz2` duy nhất trên
/// Firebase Storage (cùng định dạng tarball `tts-models` của sherpa-onnx),
/// được giải nén về thư mục model trên disk khi tải về. Dùng tar.bz2 vì
/// hầu hết model (vd Piper) cần kèm thư mục `espeak-ng-data/` — không thể
/// ship dạng vài file rời.
class TtsModelSpec {
  const TtsModelSpec({
    required this.id,
    required this.displayName,
    required this.language,
    required this.firebasePath,
    required this.archivePath,
    required this.modelRelPath,
    required this.tokensRelPath,
    required this.lexiconRelPath,
    this.sha256 = '',
    required this.license,
  });

  /// Key ổn định, dùng làm thư mục model + key cache.
  final String id;

  /// Tên hiển thị cho user (settings screen Phase B).
  final String displayName;

  /// Mã ngôn ngữ, vd `en` (mở đường cho `vi` ở phase sau).
  final String language;

  /// Đường dẫn file tar.bz2 trên Firebase Storage.
  final String firebasePath;

  /// Tên thư mục gốc bên trong archive (phần đầu mỗi path member).
  final String archivePath;

  /// Path tương đối (trong thư mục model sau khi giải nén) tới file `.onnx`.
  final String modelRelPath;

  /// Path tương đối tới `tokens.txt`.
  final String tokensRelPath;

  /// Path tương đối tới `lexicon.txt` (rỗng nếu model không cần, vd vits-vctk).
  final String lexiconRelPath;

  /// SHA-256 hex của file tar.bz2 — verify sau khi tải. Rỗng = không verify.
  final String sha256;

  /// License của model (xem docs/analysis/sherpa-onnx-replacement.md).
  final String license;
}

/// Model tiếng Anh mặc định (Phase A): `vits-vctk` — 109 speakers, chỉ cần
/// `vits-vctk.onnx` + `tokens.txt` + `lexicon.txt`, KHÔNG cần `espeak-ng-data`.
/// Dùng phiên bản `int8` (39.8 MB vs 121.3 MB) để giảm dung lượng tải.
const ttsModels = <TtsModelSpec>[
  TtsModelSpec(
    id: 'vits-vctk-int8',
    displayName: 'VCTK (English, 109 voices)',
    language: 'en',
    firebasePath: 'tts/vits-vctk.tar.bz2',
    archivePath: 'vits-vctk',
    modelRelPath: 'vits-vctk.int8.onnx',
    tokensRelPath: 'tokens.txt',
    lexiconRelPath: 'lexicon.txt',
    license: 'VCTK — CC BY 4.0 (voices), MIT (code)',
  ),
];
