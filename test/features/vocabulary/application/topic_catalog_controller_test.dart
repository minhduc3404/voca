import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/vocabulary/application/providers.dart';
import 'package:voca_app/features/vocabulary/application/topic_catalog_controller.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/downloaded_topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';
import 'package:voca_app/features/vocabulary/domain/topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/vocabulary_catalog_repository.dart';

class _FakeCatalogRepository implements VocabularyCatalogRepository {
  _FakeCatalogRepository({required this.topics, this.wordsByTopic = const {}});

  final List<Topic> topics;
  final Map<String, List<CatalogWord>> wordsByTopic;
  Object? fetchError;

  @override
  Future<List<Topic>> listTopics() async => topics;

  @override
  Future<List<CatalogWord>> fetchTopicWords(String topicId) async {
    if (fetchError != null) throw fetchError!;
    return wordsByTopic[topicId] ?? const [];
  }
}

class _FakeTopicLibraryRepository implements TopicLibraryRepository {
  final Map<String, DownloadedTopic> _downloaded = {};
  final List<(Topic, List<CatalogWord>)> importCalls = [];

  @override
  Future<List<DownloadedTopic>> getDownloadedTopics() async =>
      _downloaded.values.toList();

  @override
  Future<void> importTopic(Topic topic, List<CatalogWord> words) async {
    importCalls.add((topic, words));
    _downloaded[topic.id] = DownloadedTopic(
      topicId: topic.id,
      downloadedVersion: topic.version,
      downloadedAt: DateTime(2026, 1, 1),
    );
  }
}

const _travel = Topic(id: 'travel', name: 'Du lịch', wordCount: 1, version: 1);
const _word = CatalogWord(
  id: 'travel-001',
  term: 'itinerary',
  definition: 'lịch trình',
  phonetic: '/aɪˈtɪn.ə.rer.i/',
  partOfSpeech: 'noun',
  exampleSentence: 'Our itinerary includes three cities.',
);

void main() {
  test('build() nạp danh sách topic + trạng thái đã tải', () async {
    final catalog = _FakeCatalogRepository(
      topics: const [_travel],
      wordsByTopic: {'travel': [_word]},
    );
    final library = _FakeTopicLibraryRepository();
    final container = ProviderContainer(
      overrides: [
        vocabularyCatalogRepositoryProvider.overrideWithValue(catalog),
        topicLibraryRepositoryProvider.overrideWithValue(library),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(topicCatalogControllerProvider.future);

    expect(state.topics, [_travel]);
    expect(state.isDownloaded('travel'), isFalse);
  });

  test('downloadTopic() gọi fetchTopicWords + importTopic, cập nhật state', () async {
    final catalog = _FakeCatalogRepository(
      topics: const [_travel],
      wordsByTopic: {'travel': [_word]},
    );
    final library = _FakeTopicLibraryRepository();
    final container = ProviderContainer(
      overrides: [
        vocabularyCatalogRepositoryProvider.overrideWithValue(catalog),
        topicLibraryRepositoryProvider.overrideWithValue(library),
      ],
    );
    addTearDown(container.dispose);
    await container.read(topicCatalogControllerProvider.future);

    await container
        .read(topicCatalogControllerProvider.notifier)
        .downloadTopic(_travel);

    expect(library.importCalls, hasLength(1));
    expect(library.importCalls.single.$1, _travel);
    expect(library.importCalls.single.$2, [_word]);

    final state = container.read(topicCatalogControllerProvider).value;
    expect(state?.isDownloaded('travel'), isTrue);
    expect(state?.downloadingTopicIds, isEmpty);
  });

  test('downloadTopic() lỗi → không đổi trạng thái downloaded, rethrow', () async {
    final catalog = _FakeCatalogRepository(topics: const [_travel])
      ..fetchError = Exception('network lỗi');
    final library = _FakeTopicLibraryRepository();
    final container = ProviderContainer(
      overrides: [
        vocabularyCatalogRepositoryProvider.overrideWithValue(catalog),
        topicLibraryRepositoryProvider.overrideWithValue(library),
      ],
    );
    addTearDown(container.dispose);
    await container.read(topicCatalogControllerProvider.future);

    await expectLater(
      container.read(topicCatalogControllerProvider.notifier).downloadTopic(_travel),
      throwsException,
    );

    expect(library.importCalls, isEmpty);
    final state = container.read(topicCatalogControllerProvider).value;
    expect(state?.isDownloaded('travel'), isFalse);
    expect(state?.downloadingTopicIds, isEmpty);
  });
}
