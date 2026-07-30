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

  testWidgets('bấm nút loa gọi onSpeak, không lật thẻ', (tester) async {
    var speakCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(card: card, onSpeak: () => speakCount++),
      ),
    );

    expect(find.text('apple'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pump();

    expect(speakCount, 1);
    // Bấm nút loa không được làm lật thẻ sang mặt sau.
    expect(find.text('apple'), findsOneWidget);
    expect(find.text('quả táo'), findsNothing);
  });

  testWidgets('bấm vào thẻ (ngoài nút loa) lật sang mặt sau', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: WordCard(card: card, onSpeak: () {})),
    );

    await tester.tap(find.text('apple'));
    await tester.pump();

    expect(find.text('quả táo'), findsOneWidget);
    expect(find.text('She ate a red apple.'), findsOneWidget);
  });
}
