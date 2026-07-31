import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_app/features/study/data/tts_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Chưa lưu gì → load() trả về mặc định', () async {
    final repository = SharedPreferencesTtsSettingsRepository();

    final settings = await repository.load();

    expect(settings.speechRate, TtsSettings.defaultSpeechRate);
    expect(settings.voiceName, isNull);
    expect(settings.voiceLocale, isNull);
  });

  test('save() rồi load() → đọc lại đúng giá trị đã lưu', () async {
    final repository = SharedPreferencesTtsSettingsRepository();

    await repository.save(
      const TtsSettings(
        speechRate: 0.75,
        voiceName: 'en-us-x-tpf-local',
        voiceLocale: 'en-US',
      ),
    );
    final settings = await repository.load();

    expect(settings.speechRate, 0.75);
    expect(settings.voiceName, 'en-us-x-tpf-local');
    expect(settings.voiceLocale, 'en-US');
  });
}
