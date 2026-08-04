import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/data/tts/tts_audio_handler.dart';
import 'package:voca_app/features/study/domain/tts_service.dart';

class _FakeTtsService implements TtsService {
  final List<String> spoken = [];
  bool paused = false;
  bool resumed = false;
  bool stopped = false;
  final _events = StreamController<TtsPlaybackEvent>.broadcast();

  @override
  Future<void> warmUp() async {}

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<void> pause() async {
    paused = true;
  }

  @override
  Future<void> resume() async {
    resumed = true;
  }

  @override
  Future<List<TtsVoice>> getVoices() async => const [];

  @override
  Future<void> setVoice(TtsVoice voice) async {}

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  TtsVoice? get selectedVoice => null;

  @override
  double get speechRate => 1;

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => _events.stream;

  @override
  void dispose() {
    unawaited(_events.close());
  }

  void emit(TtsPlaybackEvent event) => _events.add(event);
}

void main() {
  late TtsAudioHandler handler;
  late _FakeTtsService inner;

  setUp(() {
    handler = TtsAudioHandler();
    inner = _FakeTtsService();
    handler.attachInner(inner);
  });

  tearDown(() => handler.dispose());

  test('speak: forward tới inner + cập nhật mediaItem/playbackState', () async {
    await handler.speak('Hi! Welcome to Café Voca.');

    expect(inner.spoken, ['Hi! Welcome to Café Voca.']);
    expect(handler.mediaItem.value?.title, 'Hi! Welcome to Café Voca.');
    expect(handler.playbackState.value.playing, isTrue);
    expect(
      handler.playbackState.value.controls,
      containsAll([MediaControl.pause, MediaControl.stop]),
    );
  });

  test('speak: title bị cắt ngắn khi text quá dài (>80 ký tự)', () async {
    final longText = 'a' * 100;
    await handler.speak(longText);

    final title = handler.mediaItem.value!.title;
    expect(title.length, 80);
    expect(title.endsWith('...'), isTrue);
  });

  test('play: gọi inner.resume() + playing = true', () async {
    await handler.play();
    expect(inner.resumed, isTrue);
    expect(handler.playbackState.value.playing, isTrue);
  });

  test('pause: gọi inner.pause() + playing = false', () async {
    await handler.pause();
    expect(inner.paused, isTrue);
    expect(handler.playbackState.value.playing, isFalse);
  });

  test('stop: gọi inner.stop() + processingState = idle', () async {
    await handler.stop();
    expect(inner.stopped, isTrue);
    expect(handler.playbackState.value.playing, isFalse);
    expect(handler.playbackState.value.processingState, AudioProcessingState.idle);
  });

  test('resume (TtsService API) tương đương play()', () async {
    await handler.resume();
    expect(inner.resumed, isTrue);
    expect(handler.playbackState.value.playing, isTrue);
  });

  test('inner phát completed → playbackState về idle/không playing', () async {
    await handler.speak('Sure! Hot or iced?');
    expect(handler.playbackState.value.playing, isTrue);

    inner.emit(const TtsPlaybackEvent.completed());
    await Future<void>.delayed(Duration.zero);

    expect(handler.playbackState.value.playing, isFalse);
    expect(handler.playbackState.value.processingState, AudioProcessingState.idle);
  });

  test('gọi trước attachInner: ném StateError', () async {
    final fresh = TtsAudioHandler();
    // speak() là async — lỗi ném ra trước await đầu tiên vẫn nằm trong
    // Future trả về, không throw đồng bộ. Phải await qua expectLater.
    await expectLater(fresh.speak('x'), throwsStateError);
  });
}
