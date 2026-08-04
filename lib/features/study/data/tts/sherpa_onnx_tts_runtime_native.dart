import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/tts_service.dart';
import 'sherpa_onnx_tts_runtime.dart';
import 'sherpa_tts_isolate.dart';
import 'tts_model_manager.dart';
import 'tts_models.dart';
import 'tts_silence_segmenter.dart';

/// Runtime mobile (Android/iOS/desktop): tải model, dựng engine sherpa-onnx
/// trong một isolate nền ([SherpaTtsIsolate]) và tách word ranges bằng silence
/// detection. Synth chạy off-main-thread nên không treo UI. Impl này được chọn
/// qua conditional import trong `sherpa_onnx_tts_runtime_factory.dart` — web
/// dùng bản no-op.
class NativeSherpaOnnxRuntime implements SherpaOnnxRuntime {
  NativeSherpaOnnxRuntime({
    required this.modelManager,
    required this.modelSpec,
    this.segmenter = const TtsSilenceSegmenter(),
    this.tokenizer = const TtsTextTokenizer(),
  });

  final TtsModelManager modelManager;
  final TtsModelSpec modelSpec;
  final TtsSilenceSegmenter segmenter;
  final TtsTextTokenizer tokenizer;

  SherpaTtsIsolate? _isolate;

  /// Future init đang chạy — dedupe các lời gọi đồng thời (`warmUp()` lúc mở
  /// app + `speak()` đầu tiên). Không có nó, nhiều lời gọi sẽ cùng tải model
  /// vào một file tạm và xoá đè lên nhau (PathNotFoundException khi verify).
  Future<void>? _engineInit;

  @override
  Future<void> warmUp() => _ensureEngine();

  /// Đảm bảo model + isolate engine sẵn sàng, chỉ chạy init MỘT lần dù bị gọi
  /// đồng thời. Init lỗi thì xoá future để lần sau thử lại (vd mất mạng).
  Future<void> _ensureEngine() {
    if (_isolate?.isReady ?? false) return Future<void>.value();
    final existing = _engineInit;
    if (existing != null) return existing;
    final future = _initEngine();
    _engineInit = future;
    unawaited(future.catchError((Object _) => _engineInit = null));
    return future;
  }

  Future<void> _initEngine() async {
    if (kDebugMode) debugPrint('_ensureEngine: ensureModel (download)...');
    final result = await modelManager.ensureModel(
      modelSpec,
      progress: kDebugMode
          ? (d, t) {
              if (t <= 0 || d == t || d % (1 << 21) < (1 << 16)) {
                debugPrint('_ensureEngine: download $d/$t');
              }
            }
          : null,
    );
    if (kDebugMode) {
      debugPrint('_ensureEngine: model ready at ${result.modelDir.path}');
    }

    final modelPath = p.join(result.modelDir.path, modelSpec.modelRelPath);
    final tokensPath = p.join(result.modelDir.path, modelSpec.tokensRelPath);
    final lexiconPath = modelSpec.lexiconRelPath.isEmpty
        ? ''
        : p.join(result.modelDir.path, modelSpec.lexiconRelPath);

    // `lexicon` và `dataDir` loại trừ nhau trong sherpa-onnx: `dataDir` trỏ
    // tới thư mục eSpeak-NG (phontab, phondata...) cho model phonemize bằng
    // espeak; `lexicon` cho model dùng từ điển sẵn. vits-vctk dùng lexicon và
    // KHÔNG có espeak-ng-data — đặt `dataDir` không rỗng khiến sherpa đi tìm
    // `phontab` → validate fail. Chỉ set `dataDir` khi model không có lexicon.
    final hasLexicon = lexiconPath.isNotEmpty;

    if (kDebugMode) debugPrint('_ensureEngine: spawning isolate engine...');
    final isolate = SherpaTtsIsolate();
    await isolate.start(
      model: modelPath,
      tokens: tokensPath,
      lexicon: lexiconPath,
      dataDir: hasLexicon ? '' : result.modelDir.path,
      numThreads: 4,
    );
    _isolate = isolate;
    if (kDebugMode) debugPrint('_ensureEngine: isolate engine ready');
  }

  @override
  Future<SherpaTtsResult> generate(
    String text, {
    required double speed,
  }) async {
    await _ensureEngine();
    if (kDebugMode) debugPrint('generate: isolate.generate("$text")...');
    final audio = await _isolate!.generate(text, speed);
    if (kDebugMode) {
      debugPrint(
        'SherpaOnnxRuntime.generate: samples=${audio.samples.length} '
        'sampleRate=${audio.sampleRate}',
      );
    }

    // Tokenize + segment ở main (rất nhẹ so với synth).
    final tokens = tokenizer.tokenize(text);
    final detected = segmenter.segment(
      audio.samples,
      sampleRate: audio.sampleRate,
      expectedWordCount: tokens.length,
    );

    final ranges = <TtsWordRange>[];
    for (final word in detected) {
      if (word.wordIndex >= tokens.length) break;
      final token = tokens[word.wordIndex];
      ranges.add(
        TtsWordRange(text: text, start: token.start, end: token.end),
      );
    }

    return SherpaTtsResult(
      samples: audio.samples,
      sampleRate: audio.sampleRate,
      wordRanges: ranges,
    );
  }

  @override
  void dispose() {
    _isolate?.dispose();
    _isolate = null;
  }
}

/// Factory (mobile): trả về native runtime. Được export qua conditional
/// import trong `sherpa_onnx_tts_runtime_factory.dart`.
SherpaOnnxRuntime createSherpaOnnxRuntime({
  required TtsModelManager modelManager,
  required TtsModelSpec modelSpec,
}) {
  return NativeSherpaOnnxRuntime(
    modelManager: modelManager,
    modelSpec: modelSpec,
  );
}
