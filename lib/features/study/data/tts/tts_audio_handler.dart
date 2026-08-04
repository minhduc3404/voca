import 'dart:async';

import 'package:audio_service/audio_service.dart';

import '../../domain/tts_service.dart';

/// Bọc [TtsService] thật (thường là `SherpaOnnxTtsService`) để phát qua
/// `audio_service` — giữ session chạy nền (Android foreground service +
/// iOS background audio mode) và hiện điều khiển play/pause/stop trên lock
/// screen/thông báo hệ thống. Đây là điểm DUY NHẤT trong app biết về
/// `audio_service` — presentation/application chỉ thấy `TtsService`.
///
/// Vòng đời 2 giai đoạn (bắt buộc vì `AudioService.init()` phải chạy TRƯỚC
/// `runApp()`, còn impl TTS thật cần DB/model manager lấy qua Riverpod nên
/// chỉ tạo được sau khi `ProviderContainer` tồn tại):
/// 1. `bootstrap()` gọi `AudioService.init(builder: TtsAudioHandler.new, ...)`
///    → có handler rỗng (chưa có inner) trước `runApp()`.
/// 2. `ttsServiceProvider` (application) tạo impl thật rồi gọi [attachInner]
///    — từ lúc này handler mới thật sự phát được.
class TtsAudioHandler extends BaseAudioHandler implements TtsService {
  TtsService? _inner;
  StreamSubscription<TtsPlaybackEvent>? _innerSub;

  /// Gọi từ `ttsServiceProvider` ngay sau khi tạo impl TTS thật.
  void attachInner(TtsService inner) {
    if (identical(_inner, inner)) return;
    unawaited(_innerSub?.cancel());
    _inner = inner;
    _innerSub = inner.playbackEvents.listen(_onInnerEvent);
  }

  TtsService get _requireInner {
    final inner = _inner;
    if (inner == null) {
      throw StateError(
        'TtsAudioHandler: attachInner() chưa được gọi trước khi dùng.',
      );
    }
    return inner;
  }

  // ---- TtsService passthrough — nghiệp vụ synth/phát vẫn ở _inner. ----

  @override
  Future<void> warmUp() => _requireInner.warmUp();

  @override
  Future<void> speak(String text) async {
    mediaItem.add(MediaItem(id: text, title: _truncate(text), album: 'Voca'));
    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        systemActions: const {MediaAction.pause, MediaAction.stop},
        playing: true,
        processingState: AudioProcessingState.ready,
      ),
    );
    await _requireInner.speak(text);
  }

  @override
  Future<List<TtsVoice>> getVoices() => _requireInner.getVoices();

  @override
  Future<void> setVoice(TtsVoice voice) => _requireInner.setVoice(voice);

  @override
  Future<void> setSpeechRate(double rate) => _requireInner.setSpeechRate(rate);

  @override
  TtsVoice? get selectedVoice => _inner?.selectedVoice;

  @override
  double get speechRate => _inner?.speechRate ?? 0.5;

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => _requireInner.playbackEvents;

  @override
  void dispose() {
    unawaited(_innerSub?.cancel());
  }

  // ---- AudioHandler — lệnh từ lock screen/thông báo hệ thống. ----

  @override
  Future<void> play() async {
    await _requireInner.resume();
    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
      ),
    );
  }

  @override
  Future<void> pause() async {
    await _requireInner.pause();
    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _requireInner.stop();
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
    await super.stop();
  }

  /// [TtsService.resume] — cùng hành vi với lệnh `play` từ lock screen.
  @override
  Future<void> resume() => play();

  void _onInnerEvent(TtsPlaybackEvent event) {
    switch (event.type) {
      case TtsPlaybackEventType.completed:
      case TtsPlaybackEventType.cancelled:
      case TtsPlaybackEventType.error:
        playbackState.add(
          playbackState.value.copyWith(
            controls: const [],
            playing: false,
            processingState: AudioProcessingState.idle,
          ),
        );
        return;
      case TtsPlaybackEventType.wordBoundary:
        return; // Không ảnh hưởng lock-screen state.
    }
  }

  String _truncate(String text) =>
      text.length > 80 ? '${text.substring(0, 77)}...' : text;
}
