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
    StudyCard(id: 1, term: 'ephemeral', definition: 'phù du, chóng tàn', language: 'en'),
    StudyCard(id: 2, term: 'resilient', definition: 'kiên cường, có sức bật', language: 'en'),
    StudyCard(id: 3, term: 'meticulous', definition: 'tỉ mỉ, cẩn thận', language: 'en'),
    StudyCard(id: 4, term: 'ambiguous', definition: 'mơ hồ, không rõ ràng', language: 'en'),
    StudyCard(id: 5, term: 'candid', definition: 'thẳng thắn, chân thật', language: 'en'),
    StudyCard(id: 6, term: 'diligent', definition: 'chăm chỉ, siêng năng', language: 'en'),
    StudyCard(id: 7, term: 'genuine', definition: 'chân thực, thật sự', language: 'en'),
    StudyCard(id: 8, term: 'inevitable', definition: 'tất yếu, không thể tránh khỏi', language: 'en'),
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
