enum PronunciationStress { none, secondary, primary }

/// Một phần chữ viết đã được catalog map thủ công tới IPA tương ứng.
///
/// [start]/[end] dùng Dart UTF-16 offset, cùng hệ quy chiếu với callback TTS.
/// `position` giữ thứ tự ổn định trong term, kể cả khi các segment bị ngăn bởi
/// khoảng trắng hoặc dấu câu.
class PronunciationSegment {
  const PronunciationSegment({
    required this.position,
    required this.start,
    required this.end,
    required this.text,
    required this.ipa,
    required this.stress,
    required this.timingWeight,
  });

  final int position;
  final int start;
  final int end;
  final String text;
  final String ipa;
  final PronunciationStress stress;
  final double timingWeight;

  bool isValidFor(String term) =>
      start >= 0 &&
      end > start &&
      end <= term.length &&
      term.substring(start, end) == text &&
      timingWeight > 0;
}
