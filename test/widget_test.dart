// Basic smoke test verifying the app boots and shows the localized title.
// Override progressRepositoryProvider để không chạm DriftProgressRepository
// thật (cần path_provider — không có platform channel trong widget test),
// và onboardingFlagRepositoryProvider để bỏ qua SharedPreferences
// (platform channel) — đi thẳng vào MainScaffold.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voca_app/app/app.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/onboarding_flag_repository.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/study_log_repository.dart';
import 'package:voca_app/features/study/domain/study_stats.dart';
import 'package:voca_app/features/study/domain/study_stats_repository.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/vocabulary/application/providers.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/downloaded_topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/vocabulary_catalog_repository.dart';

class _EmptyProgressRepository implements ProgressRepository {
  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async => const [];

  @override
  Future<WordProgress> getProgress(int cardId) async =>
      WordProgress.initial(cardId: cardId, now: DateTime.now());

  @override
  Future<void> recordAnswer(WordProgress progress) async {}
}

class _SeenOnboardingRepository extends OnboardingFlagRepository {
  @override
  Future<bool> hasSeenOnboarding() async => true;

  @override
  Future<void> markSeen() async {}
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

void main() {
  testWidgets('App shows the localized app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            _EmptyProgressRepository(),
          ),
          onboardingFlagRepositoryProvider.overrideWithValue(
            _SeenOnboardingRepository(),
          ),
          studyStatsRepositoryProvider.overrideWithValue(
            _FakeStudyStatsRepository(),
          ),
          studyLogRepositoryProvider.overrideWithValue(_FakeStudyLogRepository()),
          vocabularyCatalogRepositoryProvider.overrideWithValue(
            _FakeCatalogRepository(),
          ),
          topicLibraryRepositoryProvider.overrideWithValue(
            _FakeTopicLibraryRepository(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voca'), findsWidgets);
    expect(find.text('Khám phá'), findsOneWidget);
  });
}
