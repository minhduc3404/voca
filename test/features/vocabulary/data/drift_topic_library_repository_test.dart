import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/db/app_database.dart';
import 'package:voca_app/core/lexicon/pronunciation_segment.dart';
import 'package:voca_app/features/vocabulary/data/drift_topic_library_repository.dart';
import 'package:voca_app/features/vocabulary/domain/catalog_word.dart';
import 'package:voca_app/features/vocabulary/domain/topic.dart';

void main() {
  late AppDatabase db;
  late DriftTopicLibraryRepository repository;

  const travel = Topic(id: 'travel', name: 'Du lịch', wordCount: 2, version: 1);
  const wordA = CatalogWord(
    id: 'travel-001',
    term: 'itinerary',
    definition: 'lịch trình',
    phonetic: '/aɪˈtɪn.ə.rer.i/',
    partOfSpeech: 'noun',
    exampleSentence: 'Our itinerary includes three cities.',
    pronunciationSegments: [
      PronunciationSegment(
        position: 0,
        start: 0,
        end: 1,
        text: 'i',
        ipa: 'aɪ',
        stress: PronunciationStress.none,
        timingWeight: 1,
      ),
      PronunciationSegment(
        position: 1,
        start: 1,
        end: 4,
        text: 'tin',
        ipa: 'tɪn',
        stress: PronunciationStress.primary,
        timingWeight: 2,
      ),
    ],
  );
  const wordB = CatalogWord(
    id: 'travel-002',
    term: 'passport',
    definition: 'hộ chiếu',
    phonetic: '/ˈpæs.pɔːrt/',
    partOfSpeech: 'noun',
    exampleSentence: 'Bring your passport.',
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTopicLibraryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('importTopic lần đầu → tạo mới từ + ghi downloaded topic', () async {
    await repository.importTopic(travel, [wordA, wordB]);

    final vocab = await db.select(db.vocabularyTable).get();
    expect(vocab, hasLength(2));
    expect(
      vocab.map((v) => v.catalogId),
      containsAll(['travel-001', 'travel-002']),
    );
    expect(vocab.map((v) => v.term), containsAll(['itinerary', 'passport']));
    final segments = await db.select(db.pronunciationSegmentsTable).get();
    expect(segments.map((segment) => segment.segmentText), ['i', 'tin']);

    final downloaded = await repository.getDownloadedTopics();
    expect(downloaded, hasLength(1));
    expect(downloaded.single.topicId, 'travel');
    expect(downloaded.single.downloadedVersion, 1);
  });

  test(
    'importTopic lại (update) → không tạo trùng, giữ nguyên id + tiến độ SRS đã có',
    () async {
      await repository.importTopic(travel, [wordA]);
      final firstImport = await db.select(db.vocabularyTable).getSingle();

      // Giả lập user đã học từ này — có progress row.
      await db
          .into(db.progressTable)
          .insert(
            ProgressTableCompanion.insert(
              vocabId: firstImport.id,
              interval: 4,
              easeFactor: 2.6,
              reps: 2,
              lapses: 0,
              learningStep: const Value(null),
              nextReview: DateTime(2026, 2, 1),
              createdAt: DateTime(2026, 1, 20),
              updatedAt: DateTime(2026, 1, 20),
            ),
          );
      await db
          .into(db.ttsWordTimingCacheTable)
          .insert(
            TtsWordTimingCacheTableCompanion.insert(
              vocabId: firstImport.id,
              wordStartOffset: 0,
              wordEndOffset: 9,
              voiceKey: 'voice|en-US',
              speechRate: .5,
              durationMs: 500,
              updatedAt: DateTime(2026, 1, 20),
            ),
          );

      // Catalog sửa nội dung (definition đổi) rồi tải lại — version 2.
      const updatedWordA = CatalogWord(
        id: 'travel-001',
        term: 'itinerary',
        definition: 'lịch trình (đã sửa)',
        phonetic: '/aɪˈtɪn.ə.rer.i/',
        partOfSpeech: 'noun',
        exampleSentence: 'Our itinerary includes three cities.',
        pronunciationSegments: [],
      );
      const travelV2 = Topic(
        id: 'travel',
        name: 'Du lịch',
        wordCount: 1,
        version: 2,
      );
      await repository.importTopic(travelV2, [updatedWordA]);

      final allVocab = await db.select(db.vocabularyTable).get();
      expect(allVocab, hasLength(1)); // không tạo trùng
      expect(allVocab.single.id, firstImport.id); // giữ nguyên id
      expect(
        allVocab.single.definition,
        'lịch trình (đã sửa)',
      ); // nội dung cập nhật
      expect(await db.select(db.pronunciationSegmentsTable).get(), isEmpty);

      // Đổi term với catalogId ổn định phải loại timing offsets của term cũ.
      const renamedWordA = CatalogWord(
        id: 'travel-001',
        term: 'travel plan',
        definition: 'lịch trình (đã sửa)',
        phonetic: '/ˈtræv.əl plæn/',
        partOfSpeech: 'noun',
        exampleSentence: 'Our travel plan includes three cities.',
      );
      await repository.importTopic(travelV2, [renamedWordA]);
      expect(await db.select(db.ttsWordTimingCacheTable).get(), isEmpty);

      // Tiến độ SRS đã có không bị mất/reset.
      final progress = await (db.select(
        db.progressTable,
      )..where((t) => t.vocabId.equals(firstImport.id))).getSingle();
      expect(progress.interval, 4);
      expect(progress.reps, 2);

      final downloaded = await repository.getDownloadedTopics();
      expect(downloaded.single.downloadedVersion, 2); // version cập nhật
    },
  );

  test('từ tự nhập tay (không có catalogId) không bị ảnh hưởng', () async {
    await db
        .into(db.vocabularyTable)
        .insert(
          VocabularyTableCompanion.insert(
            term: 'manual',
            definition: 'tự nhập',
            language: 'en',
            phonetic: '/mænjuəl/',
            exampleSentence: 'A manual word.',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    await repository.importTopic(travel, [wordA]);

    final allVocab = await db.select(db.vocabularyTable).get();
    expect(allVocab, hasLength(2));
    expect(allVocab.where((v) => v.catalogId == null), hasLength(1));
  });
}
