import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/downloaded_topic.dart';
import '../domain/topic.dart';
import 'providers.dart';

class TopicCatalogState {
  const TopicCatalogState({
    required this.topics,
    required this.downloaded,
    this.downloadingTopicIds = const {},
  });

  final List<Topic> topics;

  /// `topicId` → trạng thái đã tải local, để tính đã tải chưa/có bản cập
  /// nhật không (`topic.version > downloaded[id].downloadedVersion`).
  final Map<String, DownloadedTopic> downloaded;

  /// Chủ đề đang tải dở — cho UI hiện loading trên đúng nút đang bấm,
  /// không phải loading toàn màn hình.
  final Set<String> downloadingTopicIds;

  bool isDownloaded(String topicId) => downloaded.containsKey(topicId);

  bool hasUpdate(Topic topic) {
    final current = downloaded[topic.id];
    return current != null && topic.version > current.downloadedVersion;
  }

  TopicCatalogState copyWith({Set<String>? downloadingTopicIds}) {
    return TopicCatalogState(
      topics: topics,
      downloaded: downloaded,
      downloadingTopicIds: downloadingTopicIds ?? this.downloadingTopicIds,
    );
  }
}

/// Điều phối danh sách chủ đề + tải/import — không chứa logic UI, chỉ gọi
/// [VocabularyCatalogRepository]/[TopicLibraryRepository].
class TopicCatalogController extends AsyncNotifier<TopicCatalogState> {
  @override
  Future<TopicCatalogState> build() async {
    final catalog = ref.watch(vocabularyCatalogRepositoryProvider);
    final library = ref.watch(topicLibraryRepositoryProvider);

    final topics = await catalog.listTopics();
    final downloadedList = await library.getDownloadedTopics();
    final downloaded = {
      for (final item in downloadedList) item.topicId: item,
    };

    return TopicCatalogState(topics: topics, downloaded: downloaded);
  }

  /// Tải nội dung [topic] từ catalog remote + import vào bộ học local.
  /// Dùng chung cho cả lần tải đầu tiên lẫn đồng bộ lại khi có cập nhật.
  Future<void> downloadTopic(Topic topic) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        downloadingTopicIds: {...current.downloadingTopicIds, topic.id},
      ),
    );

    try {
      final catalog = ref.read(vocabularyCatalogRepositoryProvider);
      final library = ref.read(topicLibraryRepositoryProvider);

      final words = await catalog.fetchTopicWords(topic.id);
      await library.importTopic(topic, words);

      final refreshed = await library.getDownloadedTopics();
      state = AsyncData(
        TopicCatalogState(
          topics: current.topics,
          downloaded: {for (final item in refreshed) item.topicId: item},
        ),
      );
    } catch (_) {
      // Tải lỗi (mạng, JSON hỏng...) — quay lại trạng thái trước đó, bỏ
      // cờ đang tải. Không nuốt lỗi hoàn toàn: rethrow để UI biết mà báo.
      state = AsyncData(
        current.copyWith(
          downloadingTopicIds: current.downloadingTopicIds
              .where((id) => id != topic.id)
              .toSet(),
        ),
      );
      rethrow;
    }
  }
}

final topicCatalogControllerProvider =
    AsyncNotifierProvider<TopicCatalogController, TopicCatalogState>(
      TopicCatalogController.new,
    );
