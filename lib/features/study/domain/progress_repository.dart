import 'study_card.dart';
import 'study_scope.dart';
import 'word_progress.dart';

abstract class ProgressRepository {
  /// Trả về các thẻ đến hạn ôn tại thời điểm [now], giới hạn trong [scope].
  ///
  /// Mặc định [StudyScope.all] — giữ nguyên hành vi "ôn toàn bộ bộ học".
  Future<List<StudyCard>> getDueCards(
    DateTime now, {
    StudyScope scope = const StudyScope.all(),
  });

  /// Trả về tiến độ SRS hiện tại của thẻ [cardId].
  Future<WordProgress> getProgress(int cardId);

  /// Ghi lại tiến độ SRS mới sau khi người dùng trả lời.
  Future<void> recordAnswer(WordProgress progress);
}
