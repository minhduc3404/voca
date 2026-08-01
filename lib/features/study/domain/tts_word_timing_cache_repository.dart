class TtsWordTimingCacheEntry {
  const TtsWordTimingCacheEntry({
    required this.vocabId,
    required this.wordStartOffset,
    required this.wordEndOffset,
    required this.voiceKey,
    required this.speechRate,
    required this.durationMs,
  });

  final int vocabId;
  final int wordStartOffset;
  final int wordEndOffset;
  final String voiceKey;
  final double speechRate;
  final int durationMs;
}

abstract class TtsWordTimingCacheRepository {
  Future<int?> getDurationMs({
    required int vocabId,
    required int wordStartOffset,
    required int wordEndOffset,
    required String voiceKey,
    required double speechRate,
  });

  Future<void> save(TtsWordTimingCacheEntry entry);
}
