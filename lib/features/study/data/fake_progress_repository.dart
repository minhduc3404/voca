import 'dart:collection';

import '../domain/progress_repository.dart';
import '../domain/study_card.dart';
import '../domain/word_progress.dart';

/// Implementation in-memory của [ProgressRepository] — thay bằng
/// `DriftProgressRepository` ở Phase 2 (xem PLAN-PHASE-1-2.md).
class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({DateTime? seededAt})
    : _progress = HashMap<int, WordProgress>() {
    final now = seededAt ?? DateTime.now();
    for (final card in _seedCards) {
      _progress[card.id] = WordProgress.initial(cardId: card.id, now: now);
    }
  }

  static const List<StudyCard> _seedCards = [
    StudyCard(
      id: 1,
      term: 'ephemeral',
      definition: 'phù du, chóng tàn',
      language: 'en',
      phonetic: '/ɪˈfem.ər.əl/',
      partOfSpeech: 'adj',
      exampleSentence:
          'Fame in the entertainment industry is often ephemeral.',
    ),
    StudyCard(
      id: 2,
      term: 'resilient',
      definition: 'kiên cường, có sức bật',
      language: 'en',
      phonetic: '/rɪˈzɪl.i.ənt/',
      partOfSpeech: 'adj',
      exampleSentence:
          'Children are often remarkably resilient after difficult experiences.',
    ),
    StudyCard(
      id: 3,
      term: 'meticulous',
      definition: 'tỉ mỉ, cẩn thận',
      language: 'en',
      phonetic: '/məˈtɪk.jə.ləs/',
      partOfSpeech: 'adj',
      exampleSentence:
          'She is meticulous about checking every detail of her work.',
    ),
    StudyCard(
      id: 4,
      term: 'ambiguous',
      definition: 'mơ hồ, không rõ ràng',
      language: 'en',
      phonetic: '/æmˈbɪɡ.ju.əs/',
      partOfSpeech: 'adj',
      exampleSentence:
          'His answer was so ambiguous that no one knew what he meant.',
    ),
    StudyCard(
      id: 5,
      term: 'candid',
      definition: 'thẳng thắn, chân thật',
      language: 'en',
      phonetic: '/ˈkæn.dɪd/',
      partOfSpeech: 'adj',
      exampleSentence: 'I appreciate your candid feedback on my presentation.',
    ),
    StudyCard(
      id: 6,
      term: 'diligent',
      definition: 'chăm chỉ, siêng năng',
      language: 'en',
      phonetic: '/ˈdɪl.ɪ.dʒənt/',
      partOfSpeech: 'adj',
      exampleSentence: 'She is a diligent student who never misses a deadline.',
    ),
    StudyCard(
      id: 7,
      term: 'genuine',
      definition: 'chân thực, thật sự',
      language: 'en',
      phonetic: '/ˈdʒen.ju.ɪn/',
      partOfSpeech: 'adj',
      exampleSentence:
          "He showed genuine concern for his friend's well-being.",
    ),
    StudyCard(
      id: 8,
      term: 'inevitable',
      definition: 'tất yếu, không thể tránh khỏi',
      language: 'en',
      phonetic: '/ɪˈnev.ɪ.tə.bəl/',
      partOfSpeech: 'adj',
      exampleSentence: 'Change is inevitable in any growing business.',
    ),
  ];

  final Map<int, WordProgress> _progress;

  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async {
    return _seedCards
        .where((card) => !now.isBefore(_progress[card.id]!.nextReview))
        .toList();
  }

  @override
  Future<WordProgress> getProgress(int cardId) async {
    return _progress[cardId] ??
        WordProgress.initial(cardId: cardId, now: DateTime.now());
  }

  @override
  Future<void> recordAnswer(WordProgress progress) async {
    _progress[progress.cardId] = progress;
  }
}
