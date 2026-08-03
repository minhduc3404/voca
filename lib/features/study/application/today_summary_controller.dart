import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/study_log_repository.dart';
import '../domain/study_stats.dart';
import '../domain/study_stats_repository.dart';
import 'providers.dart';

/// Trạng thái tổng hợp cho màn "Hôm nay".
class TodaySummaryState {
  const TodaySummaryState({
    required this.stats,
    required this.streak,
    required this.activeTopics,
  });

  final TodayStudyStats stats;
  final StudyStreak streak;
  final List<ActiveTopic> activeTopics;

  @override
  bool operator ==(Object other) =>
      other is TodaySummaryState &&
      other.stats == stats &&
      other.streak == streak &&
      other.activeTopics == activeTopics;

  @override
  int get hashCode => Object.hash(stats, streak, activeTopics);

  @override
  String toString() =>
      'TodaySummaryState(stats: $stats, streak: $streak, topics: $activeTopics)';
}

/// Điều phối dữ liệu cho màn "Hôm nay": gọi [StudyStatsRepository] +
/// [StudyLogRepository] rồi gộp thành [TodaySummaryState]. KHÔNG chứa
/// business logic — chỉ điều phối và gọi repository (CLAUDE.md §3).
final todaySummaryControllerProvider = AsyncNotifierProvider<
  TodaySummaryController,
  TodaySummaryState
>(TodaySummaryController.new);

class TodaySummaryController extends AsyncNotifier<TodaySummaryState> {
  @override
  Future<TodaySummaryState> build() async {
    final statsRepo = ref.watch(studyStatsRepositoryProvider);
    final logRepo = ref.watch(studyLogRepositoryProvider);
    final now = DateTime.now();

    final stats = await statsRepo.getTodayStats(now);
    final studiedDates = await logRepo.getStudyDates();
    final activeTopics = await statsRepo.getActiveTopics();

    final streak = computeStreak(
      studiedDates,
      today: dateKey(now),
    );

    return TodaySummaryState(
      stats: stats,
      streak: StudyStreak(current: streak, lastStudyDate: studiedDates.isEmpty ? null : studiedDates.reduce((a, b) => a.compareTo(b) > 0 ? a : b)),
      activeTopics: activeTopics,
    );
  }

  /// Làm mới lại khi quay về màn Hôm nay (sau phiên học) — vì data mới
  /// (streak/summary) thay đổi sau mỗi lượt trả lời.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
