// Basic smoke test verifying the app boots and shows the localized title.
// Override progressRepositoryProvider để không chạm DriftProgressRepository
// thật (cần path_provider — không có platform channel trong widget test).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voca_app/app/app.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';

class _EmptyProgressRepository implements ProgressRepository {
  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async => const [];

  @override
  Future<WordProgress> getProgress(int cardId) async =>
      WordProgress.initial(cardId: cardId, now: DateTime.now());

  @override
  Future<void> recordAnswer(WordProgress progress) async {}
}

void main() {
  testWidgets('App shows the localized app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            _EmptyProgressRepository(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voca'), findsWidgets);
  });
}
