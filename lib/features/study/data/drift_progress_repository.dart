import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/lexicon/pronunciation_segment.dart';
import '../domain/progress_repository.dart';
import '../domain/study_card.dart';
import '../domain/word_progress.dart';

/// Implementation thật của [ProgressRepository] dùng Drift/SQLite — thay
/// [FakeProgressRepository] ở Phase 2 (xem PLAN-PHASE-1-2.md).
class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async {
    final allVocab = await _db.select(_db.vocabularyTable).get();
    final dueCards = <StudyCard>[];

    for (final vocab in allVocab) {
      final progress = await (_db.select(
        _db.progressTable,
      )..where((t) => t.vocabId.equals(vocab.id))).getSingleOrNull();
      final isDue = progress == null || !now.isBefore(progress.nextReview);
      if (isDue) {
        dueCards.add(await _toStudyCard(vocab));
      }
    }

    return dueCards;
  }

  @override
  Future<WordProgress> getProgress(int cardId) async {
    final row = await (_db.select(
      _db.progressTable,
    )..where((t) => t.vocabId.equals(cardId))).getSingleOrNull();

    if (row == null) {
      return WordProgress.initial(cardId: cardId, now: DateTime.now());
    }
    return _toWordProgress(row);
  }

  @override
  Future<void> recordAnswer(WordProgress progress) async {
    final now = DateTime.now();
    final existing = await (_db.select(
      _db.progressTable,
    )..where((t) => t.vocabId.equals(progress.cardId))).getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.progressTable)
          .insert(
            ProgressTableCompanion.insert(
              vocabId: progress.cardId,
              interval: progress.interval,
              easeFactor: progress.easeFactor,
              reps: progress.reps,
              lapses: progress.lapses,
              learningStep: Value(progress.learningStep),
              nextReview: progress.nextReview,
              lastReview: Value(progress.lastReview),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(
        _db.progressTable,
      )..where((t) => t.vocabId.equals(progress.cardId))).write(
        ProgressTableCompanion(
          interval: Value(progress.interval),
          easeFactor: Value(progress.easeFactor),
          reps: Value(progress.reps),
          lapses: Value(progress.lapses),
          learningStep: Value(progress.learningStep),
          nextReview: Value(progress.nextReview),
          lastReview: Value(progress.lastReview),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<StudyCard> _toStudyCard(VocabularyTableData row) async {
    final segmentRows =
        await (_db.select(_db.pronunciationSegmentsTable)
              ..where((table) => table.vocabId.equals(row.id))
              ..orderBy([(table) => OrderingTerm.asc(table.position)]))
            .get();
    return StudyCard(
      id: row.id,
      term: row.term,
      definition: row.definition,
      language: row.language,
      phonetic: row.phonetic,
      partOfSpeech: row.partOfSpeech,
      exampleSentence: row.exampleSentence,
      pronunciationSegments: [
        for (final segment in segmentRows)
          PronunciationSegment(
            position: segment.position,
            start: segment.startOffset,
            end: segment.endOffset,
            text: segment.segmentText,
            ipa: segment.ipa,
            stress: PronunciationStress.values.byName(segment.stress),
            timingWeight: segment.timingWeight,
          ),
      ],
    );
  }

  WordProgress _toWordProgress(ProgressTableData row) {
    return WordProgress(
      cardId: row.vocabId,
      interval: row.interval,
      easeFactor: row.easeFactor,
      reps: row.reps,
      lapses: row.lapses,
      learningStep: row.learningStep,
      nextReview: row.nextReview,
      lastReview: row.lastReview,
    );
  }
}
