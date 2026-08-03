import 'sherpa_onnx_tts_runtime.dart';
import 'tts_model_manager.dart';
import 'tts_models.dart';

/// Runtime cho web — sherpa_onnx không hỗ trợ web (dùng `dart:ffi`/`dart:io`),
/// web giữ nguyên `FlutterTtsService`. Bản no-op này chỉ để conditional import
/// (`sherpa_onnx_tts_runtime_factory.dart`) biên dịch được trên web mà không
/// kéo theo native lib.
class NoopSherpaOnnxRuntime implements SherpaOnnxRuntime {
  @override
  Future<SherpaTtsResult> generate(
    String text, {
    required double speed,
  }) async {
    throw UnsupportedError(
      'sherpa-onnx không hỗ trợ web — dùng FlutterTtsService.',
    );
  }

  @override
  void dispose() {}
}

/// Factory (web): trả về no-op runtime. Được export qua conditional import
/// trong `sherpa_onnx_tts_runtime_factory.dart`.
SherpaOnnxRuntime createSherpaOnnxRuntime({
  required TtsModelManager modelManager,
  required TtsModelSpec modelSpec,
}) {
  return NoopSherpaOnnxRuntime();
}
