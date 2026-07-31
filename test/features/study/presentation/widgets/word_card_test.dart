import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('She ate a red apple.'), findsOneWidget);
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
}
