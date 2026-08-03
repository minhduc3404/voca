import 'package:flutter/foundation.dart';

import '../../domain/tts_service.dart';
import '../tts_service.dart' show FlutterTtsService;
import 'sherpa_onnx_tts_service.dart';
import 'tts_model_manager.dart';

/// Factory chọn impl `TtsService` theo platform (CLAUDE.md §8 — điểm nối
/// duy nhất application ↔ data):
/// - Mobile (Android/iOS/desktop): `SherpaOnnxTtsService` — offline, timing
///   deterministic (silence detection precompute).
/// - Web: `FlutterTtsService` — sherpa_onnx không hỗ trợ web.
class FactoryTtsService {
  FactoryTtsService({TtsModelManager? modelManager})
    : _modelManager = modelManager;

  final TtsModelManager? _modelManager;

  TtsService create() {
    if (!kIsWeb) {
      return SherpaOnnxTtsService(
        modelManager: _modelManager ?? TtsModelManager(),
      );
    }
    return FlutterTtsService();
  }
}
