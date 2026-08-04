import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/core/widgets/async_state_view.dart';

import '../application/today_summary_controller.dart';
import '../domain/study_stats.dart';
import '../domain/study_stats_repository.dart';
import 'memo_screen.dart';

/// Màn "Tiến độ học" — streak + summary + chủ đề đang học.
/// Dữ liệu từ [todaySummaryControllerProvider] (streak nghiêm: chỉ tính
/// ngày đã ôn; schema v5 StudyLogTable).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaySummaryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Tiến độ học',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const AsyncStateView(
          isLoading: true,
          errorMessage: null,
          onRetry: _noop,
          loadingLabel: 'Đang tải...',
          child: SizedBox.shrink(),
        ),
        error: (e, _) => AsyncStateView(
          isLoading: false,
          errorMessage: 'Không tải được dữ liệu hôm nay: $e',
          onRetry: () => ref
              .read(todaySummaryControllerProvider.notifier)
              .refresh(),
          child: const SizedBox.shrink(),
        ),
        data: (state) => _ProgressBody(state: state),
      ),
    );
  }
}

void _noop() {}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.state});

  final TodaySummaryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = state.stats;
    final streak = state.streak.current;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _StreakHeader(streak: streak, lastStudy: state.streak.lastStudyDate),

        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MemoScreen()),
          ),
          icon: const AppIcon('play', size: 20, color: AppColors.textPrimary),
          label: Text(
            stats.dueCount > 0
                ? 'Bắt đầu ôn tập · ${stats.dueCount} thẻ đến hạn'
                : 'Bắt đầu ôn tập',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 24),

        _SummaryGrid(stats: stats),

        if (state.activeTopics.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Chủ đề đang học',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final topic in state.activeTopics) _TopicTile(topic: topic),
        ],
      ],
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.streak, required this.lastStudy});

  final int streak;
  final String? lastStudy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentGlow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          const AppIcon('flame', size: 36, color: AppColors.accent),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak ngày liên tiếp',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lastStudy == null
                    ? 'Học một chút mỗi ngày để giữ chuỗi!'
                    : 'Chăm chỉ lắm — cố giữ chuỗi nhé!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats});

  final TodayStudyStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Cần ôn', stats.dueCount),
      ('Từ mới', stats.newCount),
      ('Đang học', stats.learningCount),
      ('Đã thuộc', stats.masteredCount),
      ('Từ yếu', stats.weakCount),
      ('Tổng vốn từ', stats.totalCount),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        for (final (label, value) in items)
          _SummaryCard(label: label, value: value),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.controlBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic});

  final ActiveTopic topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.controlBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const AppIcon('book-open', size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${topic.wordCount} từ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}
