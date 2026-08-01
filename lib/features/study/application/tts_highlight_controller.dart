import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/lexicon/pronunciation_segment.dart';
import '../domain/study_card.dart';
import '../domain/tts_service.dart';
import '../domain/tts_word_timing_cache_repository.dart';
import 'providers.dart';

/// State thuần cho presentation render vùng từ/segment đang phát.
class TtsHighlightState {
  const TtsHighlightState({
    this.wordStart,
    this.wordEnd,
    this.activeSegmentPosition,
  });

  final int? wordStart;
  final int? wordEnd;
  final int? activeSegmentPosition;
}

/// Điều phối TTS word-boundary, cache duration và lifecycle của animation.
/// Screen chỉ gọi [speak] rồi render [TtsHighlightState].
class TtsHighlightController extends Notifier<TtsHighlightState> {
  static const _fallbackSegmentUnitMs = 220;

  StreamSubscription<TtsPlaybackEvent>? _subscription;
  Timer? _segmentTimer;
  StudyCard? _activeCard;
  TtsWordRange? _activeRange;
  Stopwatch? _wordStopwatch;
  int _eventRevision = 0;

  TtsService get _tts => ref.read(ttsServiceProvider);

  TtsWordTimingCacheRepository get _cache =>
      ref.read(ttsWordTimingCacheRepositoryProvider);

  @override
  TtsHighlightState build() {
    _subscription = _tts.playbackEvents.listen(_onPlaybackEvent);
    ref.onDispose(() {
      _segmentTimer?.cancel();
      unawaited(_subscription?.cancel() ?? Future<void>.value());
    });
    return const TtsHighlightState();
  }

  Future<void> speak(StudyCard card) async {
    _clear(writeDuration: false);
    _activeCard = card;
    await _tts.speak(card.term);
  }

  void clear() => _clear(writeDuration: false);

  void _onPlaybackEvent(TtsPlaybackEvent event) {
    if (event.type == TtsPlaybackEventType.completed) {
      _clear(writeDuration: true);
      return;
    }
    if (event.type != TtsPlaybackEventType.wordBoundary) {
      _clear(writeDuration: false);
      return;
    }
    final range = event.wordRange!;
    final card = _activeCard;
    if (card == null || range.text != card.term) return;
    _finishActiveWord();
    _activeRange = range;
    _wordStopwatch = Stopwatch()..start();
    _activateRange(card, range);
  }

  void _activateRange(StudyCard card, TtsWordRange range) {
    _segmentTimer?.cancel();
    final segments = card.pronunciationSegments
        .where(
          (segment) => segment.start >= range.start && segment.end <= range.end,
        )
        .toList();
    if (segments.isEmpty) {
      state = TtsHighlightState(wordStart: range.start, wordEnd: range.end);
      return;
    }

    final revision = ++_eventRevision;
    final voiceKey = _tts.selectedVoice?.cacheKey ?? '<default>';
    final speechRate = _tts.speechRate;
    // Không chờ I/O cache mới bắt đầu animation: segment có data phải được
    // highlight ngay từ lượt phát đầu. Duration này chỉ là nhịp tạm thời,
    // được thay bằng timing đã quan sát ngay khi cache trả về.
    _startSegmentSchedule(
      segments,
      _estimateDurationMs(segments, speechRate),
      range,
    );
    unawaited(() async {
      final durationMs = await _cache.getDurationMs(
        vocabId: card.id,
        wordStartOffset: range.start,
        wordEndOffset: range.end,
        voiceKey: voiceKey,
        speechRate: speechRate,
      );
      if (revision != _eventRevision || durationMs == null || durationMs <= 0) {
        return;
      }
      _startSegmentSchedule(segments, durationMs, range);
    }());
  }

  int _estimateDurationMs(
    List<PronunciationSegment> segments,
    double speechRate,
  ) {
    final totalWeight = segments.fold<double>(
      0,
      (total, segment) => total + segment.timingWeight,
    );
    final rateFactor = .5 / speechRate.clamp(.25, 1.0);
    return (_fallbackSegmentUnitMs * totalWeight * rateFactor).round();
  }

  void _startSegmentSchedule(
    List<PronunciationSegment> segments,
    int durationMs,
    TtsWordRange range,
  ) {
    final totalWeight = segments.fold<double>(
      0,
      (total, segment) => total + segment.timingWeight,
    );
    var index = 0;

    void activateNext() {
      if (_activeRange != range || index >= segments.length) return;
      final segment = segments[index++];
      state = TtsHighlightState(
        wordStart: range.start,
        wordEnd: range.end,
        activeSegmentPosition: segment.position,
      );
      if (index >= segments.length) return;
      final delay = Duration(
        milliseconds: (durationMs * segment.timingWeight / totalWeight).round(),
      );
      _segmentTimer = Timer(delay, activateNext);
    }

    activateNext();
  }

  void _finishActiveWord() {
    final card = _activeCard;
    final range = _activeRange;
    final stopwatch = _wordStopwatch;
    if (card == null ||
        range == null ||
        stopwatch == null ||
        !stopwatch.isRunning) {
      return;
    }
    stopwatch.stop();
    final durationMs = stopwatch.elapsedMilliseconds;
    if (durationMs > 0) {
      unawaited(
        _cache.save(
          TtsWordTimingCacheEntry(
            vocabId: card.id,
            wordStartOffset: range.start,
            wordEndOffset: range.end,
            voiceKey: _tts.selectedVoice?.cacheKey ?? '<default>',
            speechRate: _tts.speechRate,
            durationMs: durationMs,
          ),
        ),
      );
    }
    _wordStopwatch = null;
  }

  void _clear({required bool writeDuration}) {
    if (writeDuration) _finishActiveWord();
    _segmentTimer?.cancel();
    _segmentTimer = null;
    _activeCard = null;
    _activeRange = null;
    _wordStopwatch = null;
    _eventRevision++;
    state = const TtsHighlightState();
  }
}

final ttsHighlightControllerProvider =
    NotifierProvider<TtsHighlightController, TtsHighlightState>(
      TtsHighlightController.new,
    );
