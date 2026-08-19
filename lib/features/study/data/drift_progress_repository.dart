import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/lexicon/pronunciation_segment.dart';
import '../domain/progress_repository.dart';
import '../domain/study_card.dart';
import '../domain/study_log_repository.dart';
import '../domain/study_scope.dart';
import '../domain/word_progress.dart';
import 'drift_study_log_repository.dart';

/// Implementation thật của [ProgressRepository] dùng Drift/SQLite — thay
/// [FakeProgressRepository] ở Phase 2 (xem PLAN-PHASE-1-2.md).
class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db, {StudyLogRepository? studyLog})
    : _studyLog = studyLog ?? DriftStudyLogRepository(_db);

  final AppDatabase _db;

  /// Ghi nhật ký ôn theo ngày (schema v5) — streak. Cùng transaction với
  /// `recordAnswer` để không bao giờ lệch (có trả lời nhưng thiếu log).
  final StudyLogRepository _studyLog;

  @override
  Future<List<StudyCard>> getDueCards(
    DateTime now, {
    StudyScope scope = const StudyScope.all(),
  }) async {
    final query = _db.select(_db.vocabularyTable);
    switch (scope.kind) {
      case StudyScopeKind.all:
        break;
      case StudyScopeKind.topic:
        // `topicId` luôn khác null khi kind == topic (bảo đảm bởi
        // constructor `StudyScope.topic`).
        query.where((t) => t.topicId.equals(scope.topicId!));
      case StudyScopeKind.manual:
        query.where((t) => t.topicId.isNull());
    }
    final allVocab = await query.get();
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
    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.progressTable,
      )..where((t) => t.vocabId.equals(progress.cardId))).getSingleOrNull();

      // Từ mới = trước khi ghi nhận chưa có progress row, hoặc có row nhưng
      // chưa từng ôn (lastReview == null). Xét từ `existing` (trạng thái DB
      // TRƯỚC khi ghi), không phải từ `progress.lastReview` — giá trị sau khi
      // scheduleNextReview luôn là now nên không dùng được.
      final isNewWord = existing == null || existing.lastReview == null;

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

      // Ghi nhật ký ngày học (streak) trong cùng transaction.
      await _studyLog.recordStudy(date: now, isNewWord: isNewWord);
    });
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
