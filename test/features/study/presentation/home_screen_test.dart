import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/wakelock_service.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/vocabulary/application/providers.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/downloaded_topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/vocabulary_catalog_repository.dart';
import 'package:voca_app/features/study/presentation/home_screen.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

class _FakeCatalogRepository implements VocabularyCatalogRepository {
  _FakeCatalogRepository(this.topics);

  final List<Topic> topics;

  @override
  Future<List<Topic>> listTopics() async => topics;

  @override
  Future<List<CatalogWord>> fetchTopicWords(String topicId) async => const [];
}

class _FakeTopicLibraryRepository implements TopicLibraryRepository {
  _FakeTopicLibraryRepository({this.downloaded = const []});

  final List<DownloadedTopic> downloaded;

  @override
  Future<List<DownloadedTopic>> getDownloadedTopics() async => downloaded;

  @override
  Future<void> importTopic(Topic topic, List<CatalogWord> words) async {}
}

class _EmptyProgressRepository implements ProgressRepository {
  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async => const [];

  @override
  Future<WordProgress> getProgress(int cardId) async =>
      WordProgress.initial(cardId: cardId, now: DateTime.now());

  @override
  Future<void> recordAnswer(WordProgress progress) async {}
}

class _FakeTtsService implements TtsService {
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
  Widget wrap(List<Topic> topics, {List<DownloadedTopic> downloaded = const []}) {
    return ProviderScope(
      overrides: [
        vocabularyCatalogRepositoryProvider.overrideWithValue(
          _FakeCatalogRepository(topics),
        ),
        topicLibraryRepositoryProvider.overrideWithValue(
          _FakeTopicLibraryRepository(downloaded: downloaded),
        ),
        // MemoScreen (push từ "Tiếp tục học") cần các provider này.
        progressRepositoryProvider.overrideWithValue(_EmptyProgressRepository()),
        ttsServiceProvider.overrideWithValue(_FakeTtsService()),
        wakelockServiceProvider.overrideWithValue(_FakeWakelockService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('hiện lời chào + danh sách chủ đề', (tester) async {
    await tester.pumpWidget(
      wrap(const [
        Topic(id: 'travel', name: 'Du lịch', wordCount: 12, version: 1),
        Topic(id: 'work', name: 'Công việc', wordCount: 30, version: 2),
      ]),
    );
    await tester.pump(); // controller build
    await tester.pump(); // async repos

    expect(find.text('Chào bạn!'), findsOneWidget);
    expect(find.text('Hôm nay bạn muốn học chủ đề gì?'), findsOneWidget);
    expect(find.text('Danh mục chủ đề'), findsOneWidget);
    expect(find.text('Du lịch'), findsOneWidget);
    expect(find.text('Công việc'), findsOneWidget);
    expect(find.text('12 từ'), findsOneWidget);
    expect(find.text('30 từ'), findsOneWidget);
  });

  testWidgets('chủ đề đã tải hiện check, chưa tải hiện tải về', (tester) async {
    await tester.pumpWidget(
      wrap(
        const [Topic(id: 'travel', name: 'Du lịch', wordCount: 12, version: 1)],
        downloaded: [
          DownloadedTopic(
            topicId: 'travel',
            downloadedVersion: 1,
            downloadedAt: DateTime(2026, 8, 1),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Đã tải'), findsOneWidget);
    expect(find.byTooltip('Tải về'), findsNothing);
  });

  testWidgets('tiếp tục học → push MemoScreen', (tester) async {
    await tester.pumpWidget(wrap(const []));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Tiếp tục học'));
    await tester.pumpAndSettle();

    // MemoScreen được push — có back (canPop).
    expect(find.byTooltip('Quay lại'), findsOneWidget);
  });
}
