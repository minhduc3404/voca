import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../study/domain/tts_service.dart';
import '../../study/application/providers.dart' as study_providers;

/// State highlight từ đang phát trong turn app của script.
class TtsTurnHighlightState {
  const TtsTurnHighlightState({this.wordStart, this.wordEnd});

  /// Offset (character) của từ đang đọc trong text turn — `null` khi không phát.
  final int? wordStart;
  final int? wordEnd;

  bool get isSpeaking => wordStart != null && wordEnd != null;
}

/// Highlight từ đang đọc (word boundary) cho turn app — riêng cho
/// conversation (không tái dùng `TtsHighlightController` của study vì nó
/// gắn `StudyCard` + pronunciation segments + cache timing).
///
/// Subscription chỉ tồn tại khi đang nói: mở trong [speak], đóng trong
/// [clear]/dispose — không leak qua các turn.
class TtsTurnHighlightController extends Notifier<TtsTurnHighlightState> {
  StreamSubscription<TtsPlaybackEvent>? _subscription;
  String? _activeText;

  /// `true` khi turn hiện tại đã phát ít nhất 1 word-boundary —
  /// dùng để lọc cancelled/error "đầu" (tàn dư utterance cũ).
  bool _hasSpokenWord = false;

  TtsService get _tts => ref.read(study_providers.ttsServiceProvider);

  @override
  TtsTurnHighlightState build() {
    ref.onDispose(() {
      unawaited(_subscription?.cancel() ?? Future<void>.value());
      _subscription = null;
      _activeText = null;
    });
    return const TtsTurnHighlightState();
  }

  /// Đọc một turn của app — highlight từ theo word boundary.
  /// Mở subscription mới (hủy cái cũ nếu có) để không nhận event cũ.
  Future<void> speak(String text) async {
    await _subscription?.cancel();
    _subscription = null;
    _activeText = text;
    _hasSpokenWord = false;
    state = const TtsTurnHighlightState();
    _subscription = _tts.playbackEvents.listen(_onPlaybackEvent);
    await _tts.speak(text);
  }

  /// Dừng highlight (khi chuyển turn / thoát).
  Future<void> clear() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeText = null;
    _hasSpokenWord = false;
    state = const TtsTurnHighlightState();
  }

  void _onPlaybackEvent(TtsPlaybackEvent event) {
    switch (event.type) {
      case TtsPlaybackEventType.wordBoundary:
        final range = event.wordRange;
        final text = _activeText;
        if (range != null && text != null && range.text == text) {
          _hasSpokenWord = true;
          state = TtsTurnHighlightState(
            wordStart: range.start,
            wordEnd: range.end,
          );
        }
        return;
      case TtsPlaybackEventType.completed:
      case TtsPlaybackEventType.cancelled:
      case TtsPlaybackEventType.error:
        // Bỏ qua cancelled/error "đầu" — chúng là tàn dư của utterance cũ
        // (stop() nội bộ của sherpa) rơi vào subscription mới, chưa từng có
        // word-boundary nào của turn hiện tại. Chỉ khi đã nói được từ nào
        // thì mới coi là kết thúc turn thật.
        if (!_hasSpokenWord) return;
        _clear();
    }
  }

  void _clear() {
    _activeText = null;
    _hasSpokenWord = false;
    state = const TtsTurnHighlightState();
  }
}

final ttsTurnHighlightControllerProvider =
    NotifierProvider.autoDispose<TtsTurnHighlightController, TtsTurnHighlightState>(
      TtsTurnHighlightController.new,
    );
