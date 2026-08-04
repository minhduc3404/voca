import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/core/widgets/async_state_view.dart';
import 'package:voca_app/features/conversation/presentation/conversation_screen.dart';
import 'package:voca_app/features/vocabulary/application/topic_catalog_controller.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/presentation/topic_list_screen.dart';

import 'memo_screen.dart';
import 'tts_test_screen.dart';

/// Màn Khám phá (TRANG CHỦ theo wireframe) — topic browser:
/// lời chào + "Tiếp tục học" + grid chủ đề từ catalog.
/// Không còn là dashboard thống kê (đã chuyển sang [ProgressScreen]).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(topicCatalogControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Khám phá',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'TTS Test',
            icon: const Icon(Icons.record_voice_over_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TtsTestScreen()),
            ),
          ),
        ],
      ),
      body: catalogAsync.when(
        loading: () => const AsyncStateView(
          isLoading: true,
          errorMessage: null,
          onRetry: _noop,
          loadingLabel: 'Đang tải...',
          child: SizedBox.shrink(),
        ),
        error: (e, _) => AsyncStateView(
          isLoading: false,
          errorMessage: 'Không tải được danh sách chủ đề: $e',
          onRetry: () =>
              ref.read(topicCatalogControllerProvider.notifier).build(),
          child: const SizedBox.shrink(),
        ),
        data: (state) => _HomeBody(state: state),
      ),
    );
  }
}

void _noop() {}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.state});

  final TopicCatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Lời chào.
        Text(
          'Chào bạn!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hôm nay bạn muốn học chủ đề gì?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textFaint,
          ),
        ),

        const SizedBox(height: 20),

        // Tiếp tục học — resume bài đang dở (placeholder nếu chưa có session).
        _ContinueLearningCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MemoScreen()),
          ),
        ),

        const SizedBox(height: 24),

        // Danh mục nội dung — hiện có Từ vựng (topic grid) và Giao tiếp
        // (conversation, mock danh mục — script list ở MVP).
        Row(
          children: [
            Text(
              'Danh mục',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 4),

        // Danh mục Giao tiếp — mock danh mục, catalogs (Firebase) sau này.
        _ConversationCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConversationScreen()),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Text(
              'Chủ đề từ vựng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopicListScreen()),
              ),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),

        const SizedBox(height: 4),

        if (state.topics.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Chưa có chủ đề nào — kiểm tra kết nối mạng.',
                style: TextStyle(color: AppColors.textFaint),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: state.topics.length,
            itemBuilder: (context, index) {
              final topic = state.topics[index];
              return _TopicCard(
                topic: topic,
                isDownloaded: state.isDownloaded(topic.id),
                isDownloading: state.downloadingTopicIds.contains(topic.id),
                hasUpdate: state.hasUpdate(topic),
                onDownload: () => _download(context, ref, topic),
              );
            },
          ),
      ],
    );
  }

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    Topic topic,
  ) async {
    try {
      await ref
          .read(topicCatalogControllerProvider.notifier)
          .downloadTopic(topic);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải chủ đề thất bại: $error')),
      );
    }
  }
}

/// Card danh mục "Giao tiếp" — mock danh mục ở MVP (không cần catalog),
/// catalogs (script từ Firebase) bổ sung sau.
class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.controlBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppIcon('chat', size: 22, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giao tiếp',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Luyện hội thoại theo kịch bản',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon('skip-next', size: 20, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card "Tiếp tục học" theo wireframe (Bài 3/6 + 5 phút).
/// Hiện tại chưa lưu session state — tạm đẩy thẳng vào MemoScreen
/// (màn học tự tính session mới). Số bài/phút là placeholder.
class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentGlow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: .25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppIcon('play', size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiếp tục học',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ôn từ vựng đã học hôm nay',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                'skip-next',
                size: 20,
                color: AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isDownloaded,
    required this.isDownloading,
    required this.hasUpdate,
    required this.onDownload,
  });

  final Topic topic;
  final bool isDownloaded;
  final bool isDownloading;
  final bool hasUpdate;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.controlBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIcon('book-open', size: 22, color: AppColors.accent),
          const Spacer(),
          Text(
            topic.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${topic.wordCount} từ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textFaint,
                  ),
                ),
              ),
              if (isDownloading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: AppIcon(
                    isDownloaded
                        ? (hasUpdate ? 'refresh' : 'check-circle')
                        : 'download',
                    size: 20,
                    color: isDownloaded
                        ? (hasUpdate ? AppColors.accent : Colors.greenAccent)
                        : AppColors.controlIcon,
                  ),
                  tooltip: hasUpdate
                      ? 'Cập nhật'
                      : (isDownloaded ? 'Đã tải' : 'Tải về'),
                  onPressed: isDownloaded && !hasUpdate ? null : onDownload,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
