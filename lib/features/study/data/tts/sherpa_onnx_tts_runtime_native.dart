import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import '../../domain/tts_service.dart';
import 'sherpa_onnx_tts_runtime.dart';
import 'tts_model_manager.dart';
import 'tts_models.dart';
import 'tts_silence_segmenter.dart';

/// Runtime mobile (Android/iOS/desktop): init native bindings, khởi tạo
/// `OfflineTts`, generate audio từ model, tách word ranges bằng silence
/// detection. Impl này được chọn qua conditional import trong
/// `sherpa_onnx_tts_runtime_factory.dart` — web dùng bản no-op.
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

  sherpa_onnx.OfflineTts? _tts;

  /// Khởi tạo engine lần đầu (chậm: load model ONNX). Gọi `initBindings()`
  /// một lần duy nhất tại đây (thay vì constructor) — tránh load native lib
  /// khi chỉ tạo service (test/unit, web fallback).
  Future<void> _ensureEngine() async {
    if (_tts != null) return;
    sherpa_onnx.initBindings();
    final result = await modelManager.ensureModel(modelSpec);

    final modelPath = p.join(result.modelDir.path, modelSpec.modelRelPath);
    final tokensPath = p.join(result.modelDir.path, modelSpec.tokensRelPath);
    final lexiconPath = modelSpec.lexiconRelPath.isEmpty
        ? ''
        : p.join(result.modelDir.path, modelSpec.lexiconRelPath);

    final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
      model: modelPath,
      tokens: tokensPath,
      lexicon: lexiconPath,
      dataDir: result.modelDir.path,
    );

    final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
      vits: vits,
      numThreads: 2,
      debug: false,
    );

    final config = sherpa_onnx.OfflineTtsConfig(
      model: modelConfig,
      maxNumSenetences: 1,
    );

    _tts = sherpa_onnx.OfflineTts(config);
  }

  @override
  Future<SherpaTtsResult> generate(
    String text, {
    required double speed,
  }) async {
    await _ensureEngine();
    final tts = _tts!;

    // Generation đồng bộ, blocking — chạy trong isolate để không treo UI
    // (model nhỏ + text ngắn nên thường < 1s, nhưng vẫn an toàn).
    final audio = await compute(
      (args) {
        final (text, speed) = args;
        return tts.generate(text: text, speed: speed);
      },
      (text, speed),
    );

    // Tokenize text → map word index sang UTF-16 offset.
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
    _tts?.free();
    _tts = null;
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
