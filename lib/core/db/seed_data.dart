import 'package:drift/drift.dart';

import 'app_database.dart';

/// Dữ liệu mẫu để app có nội dung ngay từ lần cài đầu tiên — TẠM THỜI, chỉ
/// seed cho database thật (`AppDatabase()`, không phải `.forTesting()`).
/// Sẽ bỏ khi có feature nhập từ vựng thật (PLAN.md Phase 5).
Future<void> seedInitialVocabulary(AppDatabase db) async {
  final now = DateTime.now();
  final words = <VocabularyTableCompanion>[
    VocabularyTableCompanion.insert(
      term: 'ephemeral',
      definition: 'phù du, chóng tàn',
      language: 'en',
      phonetic: '/ɪˈfem.ər.əl/',
      partOfSpeech: const Value('adj'),
      exampleSentence:
          'Fame in the entertainment industry is often ephemeral.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'resilient',
      definition: 'kiên cường, có sức bật',
      language: 'en',
      phonetic: '/rɪˈzɪl.i.ənt/',
      partOfSpeech: const Value('adj'),
      exampleSentence:
          'Children are often remarkably resilient after difficult experiences.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'meticulous',
      definition: 'tỉ mỉ, cẩn thận',
      language: 'en',
      phonetic: '/məˈtɪk.jə.ləs/',
      partOfSpeech: const Value('adj'),
      exampleSentence:
          'She is meticulous about checking every detail of her work.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'ambiguous',
      definition: 'mơ hồ, không rõ ràng',
      language: 'en',
      phonetic: '/æmˈbɪɡ.ju.əs/',
      partOfSpeech: const Value('adj'),
      exampleSentence:
          'His answer was so ambiguous that no one knew what he meant.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'candid',
      definition: 'thẳng thắn, chân thật',
      language: 'en',
      phonetic: '/ˈkæn.dɪd/',
      partOfSpeech: const Value('adj'),
      exampleSentence: 'I appreciate your candid feedback on my presentation.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'diligent',
      definition: 'chăm chỉ, siêng năng',
      language: 'en',
      phonetic: '/ˈdɪl.ɪ.dʒənt/',
      partOfSpeech: const Value('adj'),
      exampleSentence: 'She is a diligent student who never misses a deadline.',
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'genuine',
      definition: 'chân thực, thật sự',
      language: 'en',
      phonetic: '/ˈdʒen.ju.ɪn/',
      partOfSpeech: const Value('adj'),
      exampleSentence:
          "He showed genuine concern for his friend's well-being.",
      createdAt: now,
    ),
    VocabularyTableCompanion.insert(
      term: 'inevitable',
      definition: 'tất yếu, không thể tránh khỏi',
      language: 'en',
      phonetic: '/ɪˈnev.ɪ.tə.bəl/',
      partOfSpeech: const Value('adj'),
      exampleSentence: 'Change is inevitable in any growing business.',
      createdAt: now,
    ),
  ];

  await db.batch((batch) {
    batch.insertAll(db.vocabularyTable, words);
  });
}
