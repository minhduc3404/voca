import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// Phát âm text bằng text-to-speech. Interface tách riêng để test override
/// được — plugin cần platform channel không có trong `flutter test`.
abstract class TtsService {
  Future<void> speak(String text);
}

class FlutterTtsService implements TtsService {
  FlutterTtsService() : _tts = FlutterTts() {
    unawaited(_tts.setLanguage('en-US'));
  }

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) => _tts.speak(text);
}
