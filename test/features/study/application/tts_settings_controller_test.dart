import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/application/tts_settings_controller.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/tts_settings_repository.dart';

class _FakeTtsService implements TtsService {
  double? lastSpeechRate;
  TtsVoice? lastVoice;

  @override
  TtsVoice? get selectedVoice => lastVoice;

  @override
  double get speechRate => lastSpeechRate ?? 0.5;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<List<TtsVoice>> getVoices() async => const [];

  @override
  Future<void> setVoice(TtsVoice voice) async {
    lastVoice = voice;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    lastSpeechRate = rate;
  }

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => const Stream.empty();

  @override
  void dispose() {}
}

class _FakeTtsSettingsRepository implements TtsSettingsRepository {
  _FakeTtsSettingsRepository([TtsSettings? initial])
    : _settings = initial ?? TtsSettings.initial;

  TtsSettings _settings;
  int saveCount = 0;

  @override
  Future<TtsSettings> load() async => _settings;

  @override
  Future<void> save(TtsSettings settings) async {
    _settings = settings;
    saveCount++;
  }
}

void main() {
  test('build() nạp cấu hình đã lưu và áp dụng vào TtsService', () async {
    final tts = _FakeTtsService();
    final repository = _FakeTtsSettingsRepository(
      const TtsSettings(
        speechRate: 0.8,
        voiceName: 'voice-a',
        voiceLocale: 'en-GB',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(tts),
        ttsSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final settings = await container.read(ttsSettingsControllerProvider.future);

    expect(settings.speechRate, 0.8);
    expect(tts.lastSpeechRate, 0.8);
    expect(tts.lastVoice, const TtsVoice(name: 'voice-a', locale: 'en-GB'));
  });

  test('updateSpeechRate() áp dụng ngay + lưu lại + cập nhật state', () async {
    final tts = _FakeTtsService();
    final repository = _FakeTtsSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(tts),
        ttsSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(ttsSettingsControllerProvider.future);

    await container
        .read(ttsSettingsControllerProvider.notifier)
        .updateSpeechRate(0.9);

    expect(tts.lastSpeechRate, 0.9);
    expect(repository.saveCount, 1);
    expect(
      container.read(ttsSettingsControllerProvider).value?.speechRate,
      0.9,
    );
  });

  test('updateVoice() áp dụng ngay + lưu lại + cập nhật state', () async {
    final tts = _FakeTtsService();
    final repository = _FakeTtsSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(tts),
        ttsSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(ttsSettingsControllerProvider.future);

    const voice = TtsVoice(name: 'voice-b', locale: 'en-US');
    await container
        .read(ttsSettingsControllerProvider.notifier)
        .updateVoice(voice);

    expect(tts.lastVoice, voice);
    expect(repository.saveCount, 1);
    final updated = container.read(ttsSettingsControllerProvider).value;
    expect(updated?.voiceName, 'voice-b');
    expect(updated?.voiceLocale, 'en-US');
  });
}
