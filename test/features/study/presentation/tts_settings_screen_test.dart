import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/tts_settings_repository.dart';
import 'package:voca_app/features/study/presentation/tts_settings_screen.dart';

class _FakeTtsService implements TtsService {
  @override
  Future<void> warmUp() async {}

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
  TtsSettings _settings = TtsSettings.initial;
  int saveCount = 0;

  @override
  Future<TtsSettings> load() async => _settings;

  @override
  Future<void> save(TtsSettings settings) async {
    _settings = settings;
    saveCount++;
  }
}

const _voices = [
  TtsVoice(name: 'en-us-voice-1', locale: 'en-US'),
  TtsVoice(name: 'en-gb-voice-1', locale: 'en-GB'),
];

void main() {
  testWidgets('Đổi giọng đọc → gọi TtsService.setVoice + lưu lại', (
    tester,
  ) async {
    final tts = _FakeTtsService();
    final repository = _FakeTtsSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(tts),
          ttsSettingsRepositoryProvider.overrideWithValue(repository),
          availableVoicesProvider.overrideWith((ref) async => _voices),
        ],
        child: const MaterialApp(home: TtsSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('en-us-voice-1'), findsOneWidget);
    expect(find.text('en-gb-voice-1'), findsOneWidget);

    await tester.tap(find.text('en-gb-voice-1'));
    await tester.pump();
    await tester.pump();

    expect(
      tts.lastVoice,
      const TtsVoice(name: 'en-gb-voice-1', locale: 'en-GB'),
    );
    expect(repository.saveCount, 1);
  });

  testWidgets('Kéo slider tốc độ → gọi TtsService.setSpeechRate + lưu lại', (
    tester,
  ) async {
    final tts = _FakeTtsService();
    final repository = _FakeTtsSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(tts),
          ttsSettingsRepositoryProvider.overrideWithValue(repository),
          availableVoicesProvider.overrideWith((ref) async => _voices),
        ],
        child: const MaterialApp(home: TtsSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.drag(find.byType(Slider), const Offset(200, 0));
    await tester.pump();
    await tester.pump();

    // Kéo tạo nhiều sự kiện onChanged liên tiếp (mỗi bước kéo) — chỉ cần
    // xác nhận có ít nhất 1 lần áp dụng + lưu, không cố định số lần chính xác.
    expect(tts.lastSpeechRate, isNotNull);
    expect(repository.saveCount, greaterThanOrEqualTo(1));
  });
}
