import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/vocabulary/application/providers.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/downloaded_topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/vocabulary_catalog_repository.dart';
import 'package:voca_app/features/vocabulary/presentation/topic_list_screen.dart';

class _FakeCatalogRepository implements VocabularyCatalogRepository {
  _FakeCatalogRepository({required this.topics, this.wordsByTopic = const {}});

  final List<Topic> topics;
  final Map<String, List<CatalogWord>> wordsByTopic;

  @override
  Future<List<Topic>> listTopics() async => topics;

  @override
  Future<List<CatalogWord>> fetchTopicWords(String topicId) async =>
      wordsByTopic[topicId] ?? const [];
}

class _FakeTopicLibraryRepository implements TopicLibraryRepository {
  final Map<String, DownloadedTopic> _downloaded = {};

  @override
  Future<List<DownloadedTopic>> getDownloadedTopics() async =>
      _downloaded.values.toList();

  @override
  Future<void> importTopic(Topic topic, List<CatalogWord> words) async {
    _downloaded[topic.id] = DownloadedTopic(
      topicId: topic.id,
      downloadedVersion: topic.version,
      downloadedAt: DateTime(2026, 1, 1),
    );
  }
}

const _travel = Topic(id: 'travel', name: 'Du lịch', wordCount: 12, version: 1);
const _word = CatalogWord(
  id: 'travel-001',
  term: 'itinerary',
  definition: 'lịch trình',
  phonetic: '/aɪˈtɪn.ə.rer.i/',
  partOfSpeech: 'noun',
  exampleSentence: 'Our itinerary includes three cities.',
);

void main() {
  testWidgets('hiện danh sách chủ đề + bấm "Tải về" gọi import', (
    tester,
  ) async {
    final catalog = _FakeCatalogRepository(
      topics: const [_travel],
      wordsByTopic: {'travel': [_word]},
    );
    final library = _FakeTopicLibraryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyCatalogRepositoryProvider.overrideWithValue(catalog),
          topicLibraryRepositoryProvider.overrideWithValue(library),
        ],
        child: const MaterialApp(home: TopicListScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Du lịch'), findsOneWidget);
    expect(find.text('12 từ'), findsOneWidget);
    expect(find.text('Tải về'), findsOneWidget);

    await tester.tap(find.text('Tải về'));
    await tester.pump(); // bắt đầu tải (downloadingTopicIds cập nhật)
    await tester.pump(); // import xong

    expect(find.text('Đã tải'), findsOneWidget);
  });
}
