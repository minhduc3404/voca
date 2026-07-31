import 'catalog_word.dart';
import 'downloaded_topic.dart';
import 'topic.dart';

/// Quản lý trạng thái "đã tải" của các chủ đề + import nội dung vào bộ
/// học local. Không phụ thuộc domain của `study/` — import chỉ ghi
/// `VocabularyTable`; `study/` tự coi từ mới thêm (chưa có progress row)
/// là due ngay, không cần `vocabulary/` biết gì về SRS.
abstract class TopicLibraryRepository {
  Future<List<DownloadedTopic>> getDownloadedTopics();

  /// Ghi [words] vào bộ học local, match theo `CatalogWord.id` với từ đã
  /// import trước đó (nếu có) để không tạo trùng và giữ nguyên tiến độ
  /// SRS đang có trên từ đó — chỉ cập nhật nội dung (term/definition/...).
  /// Từ bị xóa khỏi [words] so với lần tải trước KHÔNG bị xóa khỏi local.
  Future<void> importTopic(Topic topic, List<CatalogWord> words);
}
