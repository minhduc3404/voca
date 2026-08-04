import 'tts_service.dart' show TtsWordRange;

/// Một mục audio TTS đã synth, đọc lại được từ cache bền vững (sống qua kill
/// app) — không cần gọi engine synth lại.
class TtsAudioCacheEntry {
  const TtsAudioCacheEntry({
    required this.filePath,
    required this.sampleRate,
    required this.wordRanges,
  });

  /// Đường dẫn file WAV trên disk — data layer phát trực tiếp từ đây, không
  /// cần nạp bytes vào RAM.
  final String filePath;

  final int sampleRate;
  final List<TtsWordRange> wordRanges;
}

/// Cache audio TTS đã synth, bền vững qua lần kill app (khác RAM cache trong
/// `SherpaOnnxTtsService` — cache đó chỉ sống trong phiên chạy hiện tại).
///
/// Impl thật (Drift + file WAV rời trên disk) nằm ở `data/` — domain chỉ
/// định nghĩa contract để `application`/`data` khác không phụ thuộc chi tiết
/// lưu trữ (CLAUDE.md §2).
abstract class TtsAudioCacheRepository {
  /// Trả về mục cache theo [cacheKey] nếu còn tồn tại (file + row còn khớp
  /// nhau), `null` nếu chưa cache hoặc cache đã hỏng (file bị xoá ngoài ý
  /// muốn — coi như miss, tự dọn row mồ côi).
  Future<TtsAudioCacheEntry?> get(String cacheKey);

  /// Ghi audio đã synth vào cache, trả về mục vừa ghi (để caller lấy ngay
  /// [TtsAudioCacheEntry.filePath] mà không cần đọc lại).
  Future<TtsAudioCacheEntry> put(
    String cacheKey, {
    required List<int> wavBytes,
    required int sampleRate,
    required List<TtsWordRange> wordRanges,
  });
}
