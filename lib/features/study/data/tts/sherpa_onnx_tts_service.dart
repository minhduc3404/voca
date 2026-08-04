import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../domain/tts_audio_cache_repository.dart';
import '../../domain/tts_service.dart';
import 'sherpa_onnx_tts_runtime.dart';
import 'sherpa_onnx_tts_runtime_factory.dart';
import 'tts_model_manager.dart';
import 'tts_models.dart';

/// Impl TTS trên mobile: generate audio bằng sherpa-onnx, tính word ranges
/// deterministic (silence detection), phát qua audioplayers, và phát
/// `playbackEvents` theo lịch precomputed — không còn phụ thuộc callback
/// native TTS, timing đúng ngay lượt đầu.
///
/// Web không dùng impl này (sherpa_onnx không hỗ trợ web) — `FlutterTtsService`
/// vẫn là fallback web, chọn qua `FactoryTtsService`.
class SherpaOnnxTtsService implements TtsService {
  SherpaOnnxTtsService({
    required TtsModelManager modelManager,
    required TtsAudioCacheRepository audioCache,
    TtsModelSpec? model,
  }) : _runtime = createSherpaOnnxRuntime(
         modelManager: modelManager,
         modelSpec: model ?? ttsModels.first,
       ),
       _audioCache = audioCache,
       _modelId = (model ?? ttsModels.first).id {
    _player = AudioPlayer();
    // iOS audio session: playback + mixWithOthers (tương đương cấu hình
    // flutter_tts trước đây; defaultToSpeaker/voicePrompt không có trong
    // audioplayers — xem analysis).
    _player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _finishPlayback(completed: true);
      } else if (state == PlayerState.stopped) {
        _finishPlayback(completed: false);
      }
    });
  }

  late AudioPlayer _player;
  final SherpaOnnxRuntime _runtime;
  final TtsAudioCacheRepository _audioCache;
  final String _modelId;
  final StreamController<TtsPlaybackEvent> _events =
      StreamController<TtsPlaybackEvent>.broadcast();

  // sherpa-onnx: `speed` là hệ số, 1.0 = tốc độ chuẩn (cao hơn = nhanh hơn,
  // thấp hơn = chậm hơn). KHÁC flutter_tts (0.5 ≈ chuẩn) — phải mặc định 1.0,
  // không thì giọng bị kéo dài chậm rề.
  double _speechRate = 1.0;
  Timer? _wordTimer;
  int _scheduleRevision = 0;
  bool _playing = false;

  /// Cache trong phiên chạy hiện tại: chỉ giữ path + metadata (không giữ
  /// bytes) — audio thật nằm trên disk qua [_audioCache], bền vững qua kill
  /// app. Map này chỉ tránh phải đọc lại DB/file cho lượt lặp tức thời
  /// (memo phát cùng từ nhiều lần liên tiếp). LRU đơn giản: remove+reinsert
  /// khi hit, quá hạn xoá key cũ nhất.
  final Map<String, _CachedAudio> _memCache = {};
  static const _maxMemCacheEntries = 64;

  @override
  Future<void> warmUp() => _runtime.warmUp();

  @override
  Future<void> speak(String text) async {
    await stop();
    _playing = true;
    if (kDebugMode) debugPrint('SherpaOnnxTtsService.speak: text="$text"');
    final key = _cacheKey(text);
    try {
      var cached = _memCache.remove(key);
      if (cached != null) {
        _memCache[key] = cached; // reinsert → most-recent
        if (kDebugMode) debugPrint('  speak: mem cache HIT');
      } else {
        final onDisk = await _audioCache.get(key);
        if (onDisk != null) {
          cached = _CachedAudio(
            source: DeviceFileSource(onDisk.filePath),
            wordRanges: onDisk.wordRanges,
            sampleRate: onDisk.sampleRate,
          );
          if (kDebugMode) debugPrint('  speak: disk cache HIT');
        } else {
          final result = await _runtime.generate(text, speed: _speechRate);
          final entry = await _audioCache.put(
            key,
            wavBytes: encodeWav(result.samples, result.sampleRate),
            sampleRate: result.sampleRate,
            wordRanges: result.wordRanges,
          );
          cached = _CachedAudio(
            source: DeviceFileSource(entry.filePath),
            wordRanges: entry.wordRanges,
            sampleRate: entry.sampleRate,
          );
          if (kDebugMode) debugPrint('  speak: synth + cached to disk');
        }
        _memCache[key] = cached;
        if (_memCache.length > _maxMemCacheEntries) {
          _memCache.remove(_memCache.keys.first);
        }
      }
      final revision = ++_scheduleRevision;
      _scheduleWordEvents(cached.wordRanges, cached.sampleRate, revision);
      await _player.play(cached.source);
    } catch (e, st) {
      _playing = false;
      if (kDebugMode) debugPrint('SherpaOnnxTtsService.speak ERROR: $e\n$st');
      _events.add(const TtsPlaybackEvent.error());
    }
  }

  /// `modelId|voiceKey|speed|normalizedText` — đổi model/giọng/tốc độ tự
  /// vô hiệu cache cũ (key không khớp, không phát nhầm audio cũ).
  String _cacheKey(String text) {
    final voiceKey = selectedVoice?.cacheKey ?? '<default>';
    final normalized = text.trim().toLowerCase();
    return '$_modelId|$voiceKey|$_speechRate|$normalized';
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
  }

  @override
  Future<void> setVoice(TtsVoice voice) async {
    // Phase B: voice → model + sid. Phase A giữ model mặc định.
    // Không lưu voice ảo — tránh ghi nhầm vào settings của flutter_tts.
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    // Model hiện có 1 spec (vits-vctk-int8). Trả về các giọng khả dụng
    // từ catalog để settings screen hiện được (Phase B sẽ map model + sid).
    return const [
      TtsVoice(name: 'VCTK (English)', locale: 'en-US'),
    ];
  }

  @override
  TtsVoice? get selectedVoice => null;

  @override
  double get speechRate => _speechRate;

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => _events.stream;

  @override
  void dispose() {
    _scheduleRevision++;
    _wordTimer?.cancel();
    _player.dispose();
    _runtime.dispose();
    unawaited(_events.close());
  }

  @override
  Future<void> stop() async {
    _scheduleRevision++;
    _wordTimer?.cancel();
    await _player.stop();
    _playing = false;
    _events.add(const TtsPlaybackEvent.cancelled());
  }

  /// Tạm dừng — dùng cho lock-screen control (`TtsAudioHandler`). LƯU Ý:
  /// các `Timer` wordBoundary đã lên lịch theo mốc thời gian tuyệt đối lúc
  /// `speak()` KHÔNG bị dừng theo — sau pause/resume, highlight của lượt
  /// đang phát có thể lệch khỏi audio (tự đúng lại ở lượt `speak()` kế
  /// tiếp). Chấp nhận được vì pause/resume chủ yếu xảy ra khi màn hình tắt
  /// (không nhìn thấy highlight lúc đó).
  @override
  Future<void> pause() async {
    if (!_playing) return;
    await _player.pause();
  }

  @override
  Future<void> resume() async {
    if (!_playing) return;
    await _player.resume();
  }

  /// Lên lịch phát wordBoundary theo thời điểm từ trong audio (sample
  /// index / sampleRate), tương đối từ lúc bắt đầu play.
  void _scheduleWordEvents(
    List<TtsWordRange> ranges,
    int sampleRate,
    int revision,
  ) {
    if (ranges.isEmpty || sampleRate <= 0) return;
    for (final range in ranges) {
      final delayMs =
          (range.start.toDouble() / sampleRate * 1000).round();
      Timer(Duration(milliseconds: delayMs), () {
        if (revision != _scheduleRevision) return;
        _events.add(
          TtsPlaybackEvent.wordBoundary(
            TtsWordRange(text: range.text, start: range.start, end: range.end),
          ),
        );
      });
    }
    // Không cần timer hoàn tất riêng — PlayerState.completed xử lý.
    _wordTimer = Timer(const Duration(days: 1), () {});
  }

  void _finishPlayback({required bool completed}) {
    if (!_playing) return;
    _playing = false;
    _scheduleRevision++;
    _wordTimer?.cancel();
    _events.add(
      completed
          ? const TtsPlaybackEvent.completed()
          : const TtsPlaybackEvent.cancelled(),
    );
  }

  /// Mã hoá PCM float [-1,1] thành WAV (PCM 16-bit) trước khi ghi vào
  /// [_audioCache]. Đặt trong data layer — application/domain không biết
  /// format audio.
  @visibleForTesting
  Uint8List encodeWav(Float32List samples, int sampleRate) {
    const bytesPerSample = 2; // PCM 16-bit
    const numChannels = 1;
    final dataSize = samples.length * bytesPerSample;
    final buffer = BytesBuilder();
    void writeString(String s) => buffer.add(s.codeUnits);
    void writeUint32(int v) =>
        buffer.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
    void writeUint16(int v) => buffer.add([v & 0xFF, (v >> 8) & 0xFF]);

    writeString('RIFF');
    writeUint32(36 + dataSize);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1); // PCM
    writeUint16(numChannels);
    writeUint32(sampleRate);
    writeUint32(sampleRate * numChannels * bytesPerSample);
    writeUint16(numChannels * bytesPerSample);
    writeUint16(16); // bits per sample
    writeString('data');
    writeUint32(dataSize);
    for (final s in samples) {
      final clamped = s.clamp(-1.0, 1.0);
      final intVal = (clamped * 32767).round();
      buffer.add([intVal & 0xFF, (intVal >> 8) & 0xFF]);
    }
    return buffer.toBytes();
  }
}

/// Một mục cache trong phiên: nguồn phát audioplayers (trỏ file trên disk)
/// + word ranges + sampleRate để phát lại mà không synth lại.
class _CachedAudio {
  const _CachedAudio({
    required this.source,
    required this.wordRanges,
    required this.sampleRate,
  });

  final Source source;
  final List<TtsWordRange> wordRanges;
  final int sampleRate;
}
