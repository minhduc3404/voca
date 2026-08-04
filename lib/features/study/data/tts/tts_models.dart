/// Catalog các model TTS offline (sherpa-onnx) mà app hỗ trợ.
///
/// Giá trị hằng, không chứa logic. Model được tải theo yêu cầu qua HTTP
/// (xem `tts_model_manager.dart`); app không bundle model vào binary.
///
/// Mô hình phân phối: mỗi model là một file `tar.bz2` duy nhất, host trên
/// GitHub Releases (CDN miễn phí, không giới hạn bandwidth thực tế cho
/// public repo — tránh giới hạn 1GB/ngày egress của Firebase Storage gói
/// Spark free). Dùng tar.bz2 vì hầu hết model (vd Piper) cần kèm thư mục
/// `espeak-ng-data/` — không thể ship dạng vài file rời.
class TtsModelSpec {
  const TtsModelSpec({
    required this.id,
    required this.displayName,
    required this.language,
    required this.downloadUrl,
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

  /// URL tải file tar.bz2 (GitHub Releases asset — CDN miễn phí, không
  /// phụ thuộc Firebase Storage/egress quota).
  final String downloadUrl;

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
/// Archive chỉ đóng gói bản `int8` (39.8 MB) + `tokens.txt` + `lexicon.txt`
/// (bỏ bản fp32 121 MB không dùng tới) — nén còn ~35 MB, thay vì 145 MB nếu
/// dùng nguyên tarball gốc của k2-fsa.
const ttsModels = <TtsModelSpec>[
  TtsModelSpec(
    id: 'vits-vctk-int8',
    displayName: 'VCTK (English, 109 voices)',
    language: 'en',
    downloadUrl:
        'https://github.com/minhduc3404/voca/releases/download/tts-models-v1/vits-vctk-int8.tar.bz2',
    archivePath: 'vits-vctk',
    modelRelPath: 'vits-vctk.int8.onnx',
    tokensRelPath: 'tokens.txt',
    lexiconRelPath: 'lexicon.txt',
    sha256:
        'b8776e2a23a4d78764b452410b8747ee66610ab2a0fba8a2308c84a5c5176cfc',
    license: 'VCTK — CC BY 4.0 (voices), MIT (code)',
  ),
];
