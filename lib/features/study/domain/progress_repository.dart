import 'study_card.dart';
import 'word_progress.dart';

abstract class ProgressRepository {
  /// Trả về các thẻ đến hạn ôn tại thời điểm [now].
  Future<List<StudyCard>> getDueCards(DateTime now);

  /// Trả về tiến độ SRS hiện tại của thẻ [cardId].
  Future<WordProgress> getProgress(int cardId);

  /// Ghi lại tiến độ SRS mới sau khi người dùng trả lời.
  Future<void> recordAnswer(WordProgress progress);
}
