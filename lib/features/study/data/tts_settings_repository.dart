import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình phát âm do người dùng chọn — CLAUDE.md §4: cấu hình UI nhẹ,
/// không phải dữ liệu domain, không cần Drift/migration.
class TtsSettings {
  const TtsSettings({required this.speechRate, this.voiceName, this.voiceLocale});

  // sherpa-onnx: 1.0 = tốc độ chuẩn (xem SherpaOnnxTtsService). Range hợp lệ
  // trên UI: 0.5 (chậm) → 2.0 (nhanh).
  static const defaultSpeechRate = 1.0;

  /// Mặc định: tốc độ trung bình, dùng giọng mặc định của hệ thống (chưa
  /// chọn giọng cụ thể).
  static const initial = TtsSettings(speechRate: defaultSpeechRate);

  final double speechRate;

  /// `null` nghĩa là chưa chọn giọng cụ thể — dùng giọng mặc định hệ thống.
  final String? voiceName;
  final String? voiceLocale;

  TtsSettings copyWith({double? speechRate, String? voiceName, String? voiceLocale}) {
    return TtsSettings(
      speechRate: speechRate ?? this.speechRate,
      voiceName: voiceName ?? this.voiceName,
      voiceLocale: voiceLocale ?? this.voiceLocale,
    );
  }
}

/// Lưu/đọc [TtsSettings]. Interface tách riêng để test override được —
/// plugin `shared_preferences` cần platform channel không có trong
/// `flutter test`.
abstract class TtsSettingsRepository {
  Future<TtsSettings> load();
  Future<void> save(TtsSettings settings);
}

class SharedPreferencesTtsSettingsRepository implements TtsSettingsRepository {
  static const _speechRateKey = 'tts_speech_rate';
  static const _voiceNameKey = 'tts_voice_name';
  static const _voiceLocaleKey = 'tts_voice_locale';

  @override
  Future<TtsSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return TtsSettings(
      speechRate:
          prefs.getDouble(_speechRateKey) ?? TtsSettings.defaultSpeechRate,
      voiceName: prefs.getString(_voiceNameKey),
      voiceLocale: prefs.getString(_voiceLocaleKey),
    );
  }

  @override
  Future<void> save(TtsSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, settings.speechRate);
    if (settings.voiceName != null) {
      await prefs.setString(_voiceNameKey, settings.voiceName!);
    }
    if (settings.voiceLocale != null) {
      await prefs.setString(_voiceLocaleKey, settings.voiceLocale!);
    }
  }
}
