import 'package:drift/drift.dart';

/// Định nghĩa Drift table — không chứa business logic (PLAN-PHASE-1-2.md).
class VocabularyTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get term => text()();
  TextColumn get definition => text()();
  TextColumn get language => text()();
  TextColumn get phonetic => text()();
  TextColumn get partOfSpeech => text()();
  TextColumn get exampleSentence => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class ProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vocabId =>
      integer().references(VocabularyTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get interval => integer()();
  RealColumn get easeFactor => real()();
  IntColumn get reps => integer()();
  IntColumn get lapses => integer()();
  DateTimeColumn get nextReview => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Mỗi từ vựng chỉ có đúng 1 dòng tiến độ SRS.
  @override
  List<Set<Column>> get uniqueKeys => [
    {vocabId},
  ];
}
