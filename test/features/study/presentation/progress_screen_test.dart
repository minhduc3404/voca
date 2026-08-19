import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/wakelock_service.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/study_scope.dart';
import 'package:voca_app/features/study/domain/study_log_repository.dart';
import 'package:voca_app/features/study/domain/study_stats.dart';
import 'package:voca_app/features/study/domain/study_stats_repository.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/study/presentation/progress_screen.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

class _FakeStudyStatsRepository implements StudyStatsRepository {
  _FakeStudyStatsRepository({
    this.stats = const TodayStudyStats(
      dueCount: 0,
      newCount: 0,
      learningCount: 0,
      masteredCount: 0,
      totalCount: 0,
      weakCount: 0,
    ),
    this.topics = const [],
  });

  final TodayStudyStats stats;
  final List<ActiveTopic> topics;

  @override
  Future<TodayStudyStats> getTodayStats(DateTime now) async => stats;

  @override
  Future<List<ActiveTopic>> getActiveTopics() async => topics;
}

class _FakeStudyLogRepository implements StudyLogRepository {
  _FakeStudyLogRepository({Set<String> dates = const {}}) : _dates = dates;

  final Set<String> _dates;

  @override
  Future<Set<String>> getStudyDates() async => _dates;

  @override
  Future<void> recordStudy({
    required DateTime date,
    required bool isNewWord,
  }) async {}
}

class _EmptyProgressRepository implements ProgressRepository {
  @override
  Future<List<StudyCard>> getDueCards(
    DateTime now, {
    StudyScope scope = const StudyScope.all(),
  }) async => const [];

  @override
  Future<WordProgress> getProgress(int cardId) async =>
      WordProgress.initial(cardId: cardId, now: DateTime.now());

  @override
  Future<void> recordAnswer(WordProgress progress) async {}
}

class _FakeTtsService implements TtsService {
  @override
  Future<void> warmUp() async {}

  @override
  TtsVoice? get selectedVoice => null;

  @override
  double get speechRate => 0.5;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<List<TtsVoice>> getVoices() async => const [];

  @override
  Future<void> setVoice(TtsVoice voice) async {}

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Stream<TtsPlaybackEvent> get playbackEvents => const Stream.empty();

  @override
  void dispose() {}
}

class _FakeWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

void main() {
  Widget wrap(StudyStatsRepository stats, StudyLogRepository log) {
    return ProviderScope(
      overrides: [
        studyStatsRepositoryProvider.overrideWithValue(stats),
        studyLogRepositoryProvider.overrideWithValue(log),
        // MemoScreen (push từ CTA) cần các provider này.
        progressRepositoryProvider.overrideWithValue(_EmptyProgressRepository()),
        ttsServiceProvider.overrideWithValue(_FakeTtsService()),
        wakelockServiceProvider.overrideWithValue(_FakeWakelockService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProgressScreen(),
      ),
    );
  }

  testWidgets('hiện streak, summary, CTA khi có dữ liệu', (tester) async {
    final stats = _FakeStudyStatsRepository(
      stats: const TodayStudyStats(
        dueCount: 5,
        newCount: 3,
        learningCount: 2,
        masteredCount: 10,
        totalCount: 20,
        weakCount: 1,
      ),
      topics: const [
        ActiveTopic(topicId: 'travel', name: 'Du lịch', wordCount: 12),
      ],
    );
    final log = _FakeStudyLogRepository(
      dates: {'2026-08-01', '2026-08-02', '2026-08-03'},
    );

    await tester.pumpWidget(wrap(stats, log));
    await tester.pump(); // controller build
    await tester.pump(); // async repos

    expect(find.text('Tiến độ học'), findsOneWidget);
    expect(find.text('3 ngày liên tiếp'), findsOneWidget);
    expect(find.textContaining('5 thẻ đến hạn'), findsOneWidget);
    expect(find.text('Cần ôn'), findsOneWidget);
    expect(find.text('Du lịch'), findsOneWidget);
    expect(find.text('12 từ'), findsOneWidget);
  });

  testWidgets('chưa học bao giờ → streak 0 + lời nhắc', (tester) async {
    final stats = _FakeStudyStatsRepository();
    final log = _FakeStudyLogRepository(dates: {});

    await tester.pumpWidget(wrap(stats, log));
    await tester.pump();
    await tester.pump();

    expect(find.text('0 ngày liên tiếp'), findsOneWidget);
    expect(find.text('Học một chút mỗi ngày để giữ chuỗi!'), findsOneWidget);
  });

  testWidgets('CTA bấm → push MemoScreen', (tester) async {
    final stats = _FakeStudyStatsRepository(
      stats: const TodayStudyStats(
        dueCount: 1,
        newCount: 1,
        learningCount: 0,
        masteredCount: 0,
        totalCount: 1,
        weakCount: 0,
      ),
    );
    final log = _FakeStudyLogRepository(dates: {'2026-08-03'});

    await tester.pumpWidget(wrap(stats, log));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.textContaining('Bắt đầu ôn tập'));
    await tester.pumpAndSettle();

    // MemoScreen được push — có back (canPop) + appBar.
    expect(find.byTooltip('Quay lại'), findsOneWidget);
  });

  testWidgets('nhóm từ tự thêm hiện nhãn "Từ tôi lưu"', (tester) async {
    final stats = _FakeStudyStatsRepository(
      topics: const [
        ActiveTopic(topicId: null, name: '', wordCount: 7),
        ActiveTopic(topicId: 'travel', name: 'Du lịch', wordCount: 3),
      ],
    );
    final log = _FakeStudyLogRepository(dates: {'2026-08-03'});

    await tester.pumpWidget(wrap(stats, log));
    await tester.pump();
    await tester.pump();

    expect(find.text('Từ tôi lưu'), findsOneWidget);
    expect(find.text('7 từ'), findsOneWidget);
    expect(find.text('Du lịch'), findsOneWidget);
  });

  testWidgets('chạm nhóm từ → push MemoScreen ôn riêng nhóm đó', (
    tester,
  ) async {
    final stats = _FakeStudyStatsRepository(
      topics: const [
        ActiveTopic(topicId: 'travel', name: 'Du lịch', wordCount: 3),
      ],
    );
    final log = _FakeStudyLogRepository(dates: {'2026-08-03'});

    await tester.pumpWidget(wrap(stats, log));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Du lịch'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Quay lại'), findsOneWidget);
  });
}
