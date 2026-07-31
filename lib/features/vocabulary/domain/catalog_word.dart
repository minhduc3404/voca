/// 1 từ trong catalog remote — chưa "thuộc về" bộ học local, chưa có
/// tiến độ SRS. Khác `StudyCard` (domain của `study/`): cái đó là từ đã
/// nhập vào `VocabularyTable`, cái này chỉ là nội dung đọc từ catalog.
class CatalogWord {
  const CatalogWord({
    required this.id,
    required this.term,
    required this.definition,
    required this.phonetic,
    required this.partOfSpeech,
    required this.exampleSentence,
  });

  /// ID ổn định, duy nhất toàn catalog (vd `"travel-001"`) — dùng làm
  /// `VocabularyTable.catalogId` khi import, để match lại đúng row lúc
  /// đồng bộ cập nhật thay vì tạo trùng.
  final String id;

  final String term;
  final String definition;
  final String phonetic;

  /// Nullable — không phải nguồn catalog nào cũng xác định được từ loại.
  final String? partOfSpeech;

  final String exampleSentence;
}
