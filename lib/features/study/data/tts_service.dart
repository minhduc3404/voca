import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// Một giọng đọc TTS cụ thể mà thiết bị hỗ trợ (vd giọng "en-US-x" khác
/// "en-GB-y"). Chỉ giữ 2 field cần cho việc chọn/lưu — bản thân
/// `flutter_tts` trả về nhiều field hơn (quality, gender, identifier trên
/// iOS) nhưng app chưa cần dùng tới.
class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

/// Phát âm text bằng text-to-speech. Interface tách riêng để test override
/// được — plugin cần platform channel không có trong `flutter test`.
abstract class TtsService {
  Future<void> speak(String text);

  /// Danh sách giọng tiếng Anh (`locale` bắt đầu bằng "en") thiết bị hỗ trợ.
  /// Rỗng nếu thiết bị/nền tảng không trả được danh sách giọng.
  Future<List<TtsVoice>> getVoices();

  Future<void> setVoice(TtsVoice voice);

  /// Tốc độ đọc theo thang của `flutter_tts` (0.0–1.0, mặc định ~0.5).
  Future<void> setSpeechRate(double rate);
}

class FlutterTtsService implements TtsService {
  FlutterTtsService() : _tts = FlutterTts() {
    unawaited(_tts.setLanguage('en-US'));
  }

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) => _tts.speak(text);

  @override
  Future<List<TtsVoice>> getVoices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (voice) => TtsVoice(
            name: '${voice['name']}',
            locale: '${voice['locale']}',
          ),
        )
        .where((voice) => voice.locale.toLowerCase().startsWith('en'))
        .toList();
  }

  @override
  Future<void> setVoice(TtsVoice voice) =>
      _tts.setVoice({'name': voice.name, 'locale': voice.locale});

  @override
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);
}
