import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/topic_catalog_controller.dart';
import '../domain/topic.dart';

/// Danh sách chủ đề từ vựng (catalog remote) — chọn 1 chủ đề để tải về
/// bộ học local. Sau khi tải, từ mới xuất hiện ngay trong luồng ôn tập
/// `study/` (không cần màn này biết gì về SRS).
class TopicListScreen extends ConsumerWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(topicCatalogControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chủ đề từ vựng')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Không tải được danh sách chủ đề: $error')),
        data: (state) => ListView.builder(
          itemCount: state.topics.length,
          itemBuilder: (context, index) {
            final topic = state.topics[index];
            final isDownloading = state.downloadingTopicIds.contains(
              topic.id,
            );
            final isDownloaded = state.isDownloaded(topic.id);
            final hasUpdate = state.hasUpdate(topic);

            return ListTile(
              title: Text(topic.name),
              subtitle: Text('${topic.wordCount} từ'),
              trailing: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FilledButton(
                      onPressed: () => _download(context, ref, topic),
                      child: Text(
                        hasUpdate
                            ? 'Cập nhật'
                            : (isDownloaded ? 'Đã tải' : 'Tải về'),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref, Topic topic) async {
    try {
      await ref
          .read(topicCatalogControllerProvider.notifier)
          .downloadTopic(topic);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tải chủ đề thất bại: $error')));
    }
  }
}
