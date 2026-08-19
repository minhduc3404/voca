import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/onboarding_flag_repository.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/wakelock_service.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/study_scope.dart';
import 'package:voca_app/features/study/domain/study_log_repository.dart';
import 'package:voca_app/features/study/domain/study_stats.dart';
import 'package:voca_app/features/study/domain/study_stats_repository.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/study/presentation/onboarding_screen.dart';
import 'package:voca_app/features/vocabulary/application/providers.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/downloaded_topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/vocabulary_catalog_repository.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

class _FakeOnboardingFlagRepository extends OnboardingFlagRepository {
  _FakeOnboardingFlagRepository({bool seen = false}) : _seen = seen;

  bool _seen;

  @override
  Future<bool> hasSeenOnboarding() async => _seen;

  @override
  Future<void> markSeen() async {
    _seen = true;
  }
}

class _FakeCatalogRepository implements VocabularyCatalogRepository {
  @override
  Future<List<Topic>> listTopics() async => const [];

  @override
  Future<List<CatalogWord>> fetchTopicWords(String topicId) async => const [];
}

class _FakeTopicLibraryRepository implements TopicLibraryRepository {
  @override
  Future<List<DownloadedTopic>> getDownloadedTopics() async => const [];

  @override
  Future<void> importTopic(Topic topic, List<CatalogWord> words) async {}
}

class _FakeStudyStatsRepository implements StudyStatsRepository {
  @override
  Future<TodayStudyStats> getTodayStats(DateTime now) async =>
      const TodayStudyStats(
        dueCount: 0,
        newCount: 0,
        learningCount: 0,
        masteredCount: 0,
        totalCount: 0,
        weakCount: 0,
      );

  @override
  Future<List<ActiveTopic>> getActiveTopics() async => const [];
}

class _FakeStudyLogRepository implements StudyLogRepository {
  @override
  Future<Set<String>> getStudyDates() async => const {};

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
  Widget wrap(OnboardingFlagRepository repo) {
    return ProviderScope(
      overrides: [
        onboardingFlagRepositoryProvider.overrideWithValue(repo),
        // MainScaffold (sau khi finish) cần các provider này.
        vocabularyCatalogRepositoryProvider.overrideWithValue(
          _FakeCatalogRepository(),
        ),
        topicLibraryRepositoryProvider.overrideWithValue(
          _FakeTopicLibraryRepository(),
        ),
        studyStatsRepositoryProvider.overrideWithValue(
          _FakeStudyStatsRepository(),
        ),
        studyLogRepositoryProvider.overrideWithValue(_FakeStudyLogRepository()),
        progressRepositoryProvider.overrideWithValue(_EmptyProgressRepository()),
        ttsServiceProvider.overrideWithValue(_FakeTtsService()),
        wakelockServiceProvider.overrideWithValue(_FakeWakelockService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
  }

  testWidgets('màn 1: giới thiệu + nút Tiếp tục', (tester) async {
    await tester.pumpWidget(wrap(_FakeOnboardingFlagRepository()));

    expect(
      find.text('Học tiếng Anh bằng cách nghe và lặp lại tự nhiên'),
      findsOneWidget,
    );
    expect(find.text('Tiếp tục'), findsOneWidget);
  });

  testWidgets('bấm Tiếp tục 2 lần → màn cuối Bắt đầu học', (tester) async {
    await tester.pumpWidget(wrap(_FakeOnboardingFlagRepository()));

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Bắt đầu học'), findsOneWidget);
  });

  testWidgets('Bắt đầu học → markSeen + đẩy MainScaffold', (tester) async {
    final repo = _FakeOnboardingFlagRepository();
    await tester.pumpWidget(wrap(repo));

    // Đi tới màn cuối.
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bắt đầu học'));
    await tester.pumpAndSettle();

    expect(repo._seen, isTrue);
    // MainScaffold có bottom nav "Khám phá".
    expect(find.text('Khám phá'), findsOneWidget);
  });
}
