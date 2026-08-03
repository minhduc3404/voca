import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/study_log_repository.dart';
import '../domain/study_stats.dart' show dateKey;

/// Implementation thật của [StudyLogRepository] dùng Drift/SQLite — ghi vào
/// `StudyLogTable` (schema v5), nguồn cho streak.
class DriftStudyLogRepository implements StudyLogRepository {
  DriftStudyLogRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Set<String>> getStudyDates() async {
    final rows = await _db.select(_db.studyLogTable).get();
    return rows.map((row) => row.date).toSet();
  }

  @override
  Future<void> recordStudy({
    required DateTime date,
    required bool isNewWord,
  }) async {
    final key = dateKey(date);
    final existing = await (_db.select(
      _db.studyLogTable,
    )..where((t) => t.date.equals(key))).getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.studyLogTable).insert(
        StudyLogTableCompanion.insert(
          date: key,
          reviewCount: 1,
          newCount: isNewWord ? 1 : 0,
          updatedAt: date,
        ),
      );
    } else {
      await (_db.update(
        _db.studyLogTable,
      )..where((t) => t.date.equals(key))).write(
        StudyLogTableCompanion(
          reviewCount: Value(existing.reviewCount + 1),
          newCount: Value(existing.newCount + (isNewWord ? 1 : 0)),
          updatedAt: Value(date),
        ),
      );
    }
  }
}
