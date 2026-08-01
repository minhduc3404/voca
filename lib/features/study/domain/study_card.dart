import '../../../core/lexicon/pronunciation_segment.dart';

class StudyCard {
  const StudyCard({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
    required this.phonetic,
    required this.exampleSentence,
    this.partOfSpeech,
    this.pronunciationSegments = const [],
  });

  final int id;

  /// Từ tiếng Anh cần học — mặt trước của thẻ.
  final String term;

  /// Nghĩa tiếng Việt — mặt sau của thẻ.
  final String definition;

  /// Ngôn ngữ của [term]. Hiện cố định `'en'`.
  final String language;

  /// Phiên âm IPA.
  final String phonetic;

  /// Câu ví dụ có dùng [term].
  final String exampleSentence;

  /// Từ loại (noun/verb/adj...). Có thể `null` nếu nguồn dữ liệu không xác
  /// định được — UI phải tự xử lý khi thiếu.
  final String? partOfSpeech;

  final List<PronunciationSegment> pronunciationSegments;
}
