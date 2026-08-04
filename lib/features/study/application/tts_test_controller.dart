import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tts/tts_models.dart';
import '../domain/tts_service.dart';
import 'providers.dart';

/// State cho màn TTS test/diagnostics — log độc lập cho việc tải model và
/// phát âm, tách khỏi luồng học (memo_screen) để test riêng biệt.
class TtsTestState {
  const TtsTestState({
    this.logs = const [],
    this.downloading = false,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.speaking = false,
    this.speed = 1.0,
  });

  final List<String> logs;
  final bool downloading;
  final int downloadedBytes;
  final int totalBytes;
  final bool speaking;

  /// Hệ số tốc độ sherpa (1.0 = chuẩn, cao hơn = nhanh hơn).
  final double speed;

  double get progress =>
      totalBytes > 0 ? downloadedBytes / totalBytes : 0;

  TtsTestState copyWith({
    List<String>? logs,
    bool? downloading,
    int? downloadedBytes,
    int? totalBytes,
    bool? speaking,
    double? speed,
  }) {
    return TtsTestState(
      logs: logs ?? this.logs,
      downloading: downloading ?? this.downloading,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speaking: speaking ?? this.speaking,
      speed: speed ?? this.speed,
    );
  }
}

/// Điều phối màn test TTS: tải/xoá model với progress, phát âm thử, và gom
/// log hiển thị ngay trên màn hình (không phụ thuộc logcat). Screen chỉ gọi
/// các method dưới đây rồi render [TtsTestState].
class TtsTestController extends Notifier<TtsTestState> {
  static const _maxLogLines = 300;
  StreamSubscription<TtsPlaybackEvent>? _subscription;
  Stopwatch? _speakWatch;

  @override
  TtsTestState build() {
    // Lắng nghe event phát âm để log completed/cancelled/error + word boundary.
    _subscription = ref.read(ttsServiceProvider).playbackEvents.listen(
      _onPlaybackEvent,
    );
    ref.onDispose(() => _subscription?.cancel());
    return const TtsTestState();
  }

  void _log(String message) {
    final ts = DateTime.now().toIso8601String().substring(11, 23);
    final next = [...state.logs, '$ts  $message'];
    state = state.copyWith(
      logs: next.length > _maxLogLines
          ? next.sublist(next.length - _maxLogLines)
          : next,
    );
  }

  void _onPlaybackEvent(TtsPlaybackEvent event) {
    switch (event.type) {
      case TtsPlaybackEventType.wordBoundary:
        final r = event.wordRange;
        _log('  ↳ wordBoundary [${r?.start}..${r?.end}]');
      case TtsPlaybackEventType.completed:
        final ms = _speakWatch?.elapsedMilliseconds;
        _log('event: completed${ms == null ? '' : ' (tổng ${ms}ms)'}');
        state = state.copyWith(speaking: false);
      case TtsPlaybackEventType.cancelled:
        _log('event: cancelled');
        state = state.copyWith(speaking: false);
      case TtsPlaybackEventType.error:
        _log('event: ERROR (xem log gốc để biết chi tiết)');
        state = state.copyWith(speaking: false);
    }
  }

  /// Tải model (nếu chưa có) và log tiến độ. Đã có sẵn thì trả về ngay.
  Future<void> ensureModel() async {
    final spec = ttsModels.first;
    _log('ensureModel "${spec.id}": bắt đầu…');
    state = state.copyWith(downloading: true, downloadedBytes: 0, totalBytes: 0);
    final watch = Stopwatch()..start();
    try {
      await ref.read(ttsModelManagerProvider).ensureModel(
        spec,
        progress: (downloaded, total) {
          state = state.copyWith(
            downloadedBytes: downloaded,
            totalBytes: total,
          );
        },
      );
      _log('ensureModel: sẵn sàng sau ${watch.elapsedMilliseconds}ms');
    } catch (error) {
      _log('ensureModel LỖI: $error');
    } finally {
      state = state.copyWith(downloading: false);
    }
  }

  /// Xoá model khỏi disk để test lại luồng tải từ đầu.
  Future<void> deleteModel() async {
    await ref.read(ttsModelManagerProvider).removeModel(ttsModels.first);
    _log('đã xoá model khỏi disk (lần sau sẽ tải lại)');
    state = state.copyWith(downloadedBytes: 0, totalBytes: 0);
  }

  /// Phát âm thử một đoạn text và log thời gian tới lúc bắt đầu phát.
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _log('speak: bỏ qua (text rỗng)');
      return;
    }
    _log('speak: "$trimmed"');
    state = state.copyWith(speaking: true);
    _speakWatch = Stopwatch()..start();
    try {
      await ref.read(ttsServiceProvider).speak(trimmed);
      _log('speak: bắt đầu phát sau ${_speakWatch!.elapsedMilliseconds}ms');
    } catch (error) {
      _log('speak LỖI: $error');
      state = state.copyWith(speaking: false);
    }
  }

  /// Đổi tốc độ đọc (áp dụng cho lượt speak sau). Cache key gồm speed nên đổi
  /// tốc độ không phát lại audio cache ở tốc độ cũ.
  Future<void> setSpeed(double speed) async {
    await ref.read(ttsServiceProvider).setSpeechRate(speed);
    _log('setSpeed: ${speed.toStringAsFixed(2)}×');
    state = state.copyWith(speed: speed);
  }

  void clearLogs() => state = state.copyWith(logs: const []);
}

final ttsTestControllerProvider =
    NotifierProvider<TtsTestController, TtsTestState>(TtsTestController.new);
