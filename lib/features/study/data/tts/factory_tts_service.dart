import 'package:flutter/foundation.dart';

import '../../domain/tts_audio_cache_repository.dart';
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
  FactoryTtsService({
    required TtsAudioCacheRepository audioCache,
    TtsModelManager? modelManager,
  }) : _audioCache = audioCache,
       _modelManager = modelManager;

  final TtsAudioCacheRepository _audioCache;
  final TtsModelManager? _modelManager;

  TtsService create() {
    if (!kIsWeb) {
      return SherpaOnnxTtsService(
        modelManager: _modelManager ?? TtsModelManager(),
        audioCache: _audioCache,
      );
    }
    return FlutterTtsService();
  }
}
