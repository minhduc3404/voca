import 'dart:typed_data';

import '../../domain/tts_service.dart';

/// Kết quả tạo audio + word ranges — data layer nội bộ, application chỉ
/// nhận qua `playbackEvents` (contract `TtsService` không đổi).
class SherpaTtsResult {
  const SherpaTtsResult({
    required this.samples,
    required this.sampleRate,
    required this.wordRanges,
  });

  final Float32List samples;
  final int sampleRate;

  /// Word ranges UTF-16 (offset trong text), theo thứ tự thời gian.
  final List<TtsWordRange> wordRanges;
}

/// Khởi tạo engine + generate (mobile-only). Impl tách file để web dùng
/// conditional import tránh `dart:ffi`/`dart:io` (sherpa_onnx không hỗ trợ web).
abstract class SherpaOnnxRuntime {
  /// Tải model + dựng engine trước (isolate nền) mà không synth — gọi lúc
  /// mở app để lượt `speak()` đầu không phải chờ. Idempotent.
  Future<void> warmUp();

  Future<SherpaTtsResult> generate(String text, {required double speed});
  void dispose();
}
