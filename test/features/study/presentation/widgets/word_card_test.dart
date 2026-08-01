import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/presentation/widgets/word_card.dart';

void main() {
  const card = StudyCard(
    id: 1,
    term: 'apple',
    definition: 'quả táo',
    language: 'en',
    phonetic: '/ˈæp.əl/',
    partOfSpeech: 'noun',
    exampleSentence: 'She ate a red apple.',
  );

  testWidgets('hiện đủ term + definition + example cùng lúc, không cần lật', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: WordCard(card: card, onSpeak: () {})),
    );

    expect(find.text('apple'), findsOneWidget);
    expect(find.text('quả táo'), findsOneWidget);
    expect(find.text('"She ate a red apple."'), findsOneWidget);
  });

  testWidgets('bấm nút loa gọi onSpeak', (tester) async {
    var speakCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(card: card, onSpeak: () => speakCount++),
      ),
    );

    await tester.tap(find.byKey(const Key('word-card-speak-button')));
    await tester.pump();

    expect(speakCount, 1);
  });

  testWidgets('speakingWordIndex tô sáng đúng từ trong term nhiều từ', (
    tester,
  ) async {
    const phraseCard = StudyCard(
      id: 2,
      term: 'look forward to',
      definition: 'mong chờ',
      language: 'en',
      phonetic: '/lʊk/',
      exampleSentence: 'I look forward to it.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(
          card: phraseCard,
          onSpeak: () {},
          speakingWordIndex: 1,
        ),
      ),
    );

    final forwardText = tester.widget<Text>(find.text('forward'));
    expect(forwardText.style?.color, AppColors.accent);

    final lookText = tester.widget<Text>(find.text('look'));
    expect(lookText.style?.color, isNot(AppColors.accent));
  });
}
