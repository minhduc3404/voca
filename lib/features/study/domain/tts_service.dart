/// Một giọng đọc TTS cụ thể mà thiết bị hỗ trợ.
class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  String get cacheKey => '$name|$locale';

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

/// Word-boundary event của native TTS, offset trong text đã gửi vào speak().
class TtsWordRange {
  const TtsWordRange({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final int start;
  final int end;
}

/// Loại event do native TTS phát ra.
///
/// Completion là tín hiệu duy nhất xác nhận duration của từ cuối có thể được
/// lưu vào cache. Cancel/error không được dùng làm timing data.
enum TtsPlaybackEventType { wordBoundary, completed, cancelled, error }

/// Event TTS đã chuẩn hoá, không để application phụ thuộc callback của plugin.
class TtsPlaybackEvent {
  const TtsPlaybackEvent._(this.type, {this.wordRange});

  const TtsPlaybackEvent.wordBoundary(TtsWordRange wordRange)
    : this._(TtsPlaybackEventType.wordBoundary, wordRange: wordRange);

  const TtsPlaybackEvent.completed() : this._(TtsPlaybackEventType.completed);

  const TtsPlaybackEvent.cancelled() : this._(TtsPlaybackEventType.cancelled);

  const TtsPlaybackEvent.error() : this._(TtsPlaybackEventType.error);

  final TtsPlaybackEventType type;
  final TtsWordRange? wordRange;
}

/// Contract độc lập platform cho phát âm và word-boundary callback.
abstract class TtsService {
  Future<void> speak(String text);

  Future<List<TtsVoice>> getVoices();

  Future<void> setVoice(TtsVoice voice);

  Future<void> setSpeechRate(double rate);

  TtsVoice? get selectedVoice => null;

  double get speechRate => 0.5;

  Stream<TtsPlaybackEvent> get playbackEvents;

  void dispose();
}
