import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/data/tts/factory_tts_service.dart';
import 'package:voca_app/features/study/data/tts/sherpa_onnx_tts_service.dart';
import 'package:voca_app/features/study/data/tts/tts_model_manager.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/domain/tts_audio_cache_repository.dart';
import 'package:voca_app/features/study/domain/tts_service.dart';

class _FakeTtsAudioCacheRepository implements TtsAudioCacheRepository {
  @override
  Future<TtsAudioCacheEntry?> get(String cacheKey) async => null;

  @override
  Future<TtsAudioCacheEntry> put(
    String cacheKey, {
    required List<int> wavBytes,
    required int sampleRate,
    required List<TtsWordRange> wordRanges,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FactoryTtsService', () {
    test('trên native (không web) trả về SherpaOnnxTtsService', () {
      final factory = FactoryTtsService(
        modelManager: TtsModelManager(),
        audioCache: _FakeTtsAudioCacheRepository(),
      );
      final service = factory.create();
      expect(service, isA<SherpaOnnxTtsService>());
      expect(service, isA<TtsService>());
      service.dispose();
    });
  });
}
