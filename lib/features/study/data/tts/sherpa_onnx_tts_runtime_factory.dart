/// Conditional import: mobile (Android/iOS/desktop) dùng native sherpa-onnx,
/// web dùng no-op (sherpa_onnx không hỗ trợ web — `dart:ffi`/`dart:io`).
library;

export 'sherpa_onnx_tts_runtime_native.dart'
    if (dart.library.js_interop) 'sherpa_onnx_tts_runtime_web.dart';
