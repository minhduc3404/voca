import 'catalog_word.dart';
import 'topic.dart';

/// Đọc catalog từ vựng từ nguồn remote (Firebase Storage). Interface tách
/// riêng để test override được — implementation thật cần platform
/// channel/network không có trong `flutter test`.
abstract class VocabularyCatalogRepository {
  Future<List<Topic>> listTopics();

  Future<List<CatalogWord>> fetchTopicWords(String topicId);
}
