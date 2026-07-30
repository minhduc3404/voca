import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/study/presentation/memo_screen.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

class _InMemoryRepository implements ProgressRepository {
  _InMemoryRepository(this.cards, DateTime now)
    : _progress = {
        for (final card in cards)
          card.id: WordProgress.initial(cardId: card.id, now: now),
      };

  final List<StudyCard> cards;
  final Map<int, WordProgress> _progress;

  @override
  Future<List<StudyCard>> getDueCards(DateTime now) async => cards;

  @override
  Future<WordProgress> getProgress(int cardId) async => _progress[cardId]!;

  @override
  Future<void> recordAnswer(WordProgress progress) async {
    _progress[progress.cardId] = progress;
  }
}

void main() {
  testWidgets(
    'Flow end-to-end: màn hình → controller → scheduler → repo → UI update',
    (tester) async {
      final now = DateTime(2026, 1, 15);
      final cards = [
        const StudyCard(
          id: 1,
          term: 'apple',
          definition: 'quả táo',
          language: 'en',
          phonetic: '/ˈæp.əl/',
          partOfSpeech: 'noun',
          exampleSentence: 'She ate a red apple.',
        ),
        const StudyCard(
          id: 2,
          term: 'banana',
          definition: 'quả chuối',
          language: 'en',
          phonetic: '/bəˈnɑː.nə/',
          partOfSpeech: 'noun',
          exampleSentence: 'He bought a bunch of bananas.',
        ),
      ];
      final repository = _InMemoryRepository(cards, now);

      await tester.pumpWidget(
        ProviderScope(
          // Repository inject qua provider, override được cho test.
          overrides: [
            progressRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MemoScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('apple'), findsOneWidget);

      await tester.tap(find.text('Good'));
      await tester.pump(); // setState(_showSaved = true)
      expect(find.text('Đã lưu!'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700)); // qua transient

      expect(find.text('banana'), findsOneWidget);

      await tester.tap(find.text('Good'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Đã ôn hết thẻ đến hạn hôm nay'), findsOneWidget);
    },
  );
}
