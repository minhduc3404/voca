import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../domain/tts_service.dart';

export '../domain/tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService() : _tts = FlutterTts() {
    unawaited(_tts.setSharedInstance(true));
    unawaited(
      _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      ),
    );
    unawaited(_tts.setLanguage('en-US'));
    _tts.setProgressHandler((text, start, end, word) {
      _playbackEventController.add(
        TtsPlaybackEvent.wordBoundary(
          TtsWordRange(text: text, start: start, end: end),
        ),
      );
    });
    _tts.setCompletionHandler(
      () => _playbackEventController.add(const TtsPlaybackEvent.completed()),
    );
    _tts.setCancelHandler(
      () => _playbackEventController.add(const TtsPlaybackEvent.cancelled()),
    );
    _tts.setErrorHandler(
      (message) => _playbackEventController.add(const TtsPlaybackEvent.error()),
    );
  }

  final FlutterTts _tts;
  final _playbackEventController =
      StreamController<TtsPlaybackEvent>.broadcast();
  TtsVoice? _selectedVoice;
  double _speechRate = 0.5;

  @override
  Stream<TtsPlaybackEvent> get playbackEvents =>
      _playbackEventController.stream;

  @override
  TtsVoice? get selectedVoice => _selectedVoice;

  @override
  double get speechRate => _speechRate;

  @override
  Future<void> warmUp() async {
    // flutter_tts dùng engine hệ điều hành, không cần chuẩn bị trước.
  }

  @override
  Future<void> speak(String text) {
    return _tts.speak(text);
  }

  @override
  void dispose() {
    unawaited(_playbackEventController.close());
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (voice) =>
              TtsVoice(name: '${voice['name']}', locale: '${voice['locale']}'),
        )
        .where((voice) => voice.locale.toLowerCase().startsWith('en'))
        .toList();
  }

  @override
  Future<void> setVoice(TtsVoice voice) async {
    _selectedVoice = voice;
    await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _tts.setSpeechRate(rate);
  }
}
