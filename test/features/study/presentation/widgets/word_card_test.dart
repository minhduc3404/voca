import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/core/lexicon/pronunciation_segment.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/presentation/widgets/word_card.dart';

Color? _colorOf(WidgetTester tester, String text) {
  final animatedStyle = tester.widget<AnimatedDefaultTextStyle>(
    find.ancestor(
      of: find.text(text),
      matching: find.byType(AnimatedDefaultTextStyle),
    ),
  );
  return animatedStyle.style.color;
}

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

  testWidgets('hiện đủ nội dung khi không có segment catalog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(card: card, onSpeak: () {}),
      ),
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
    expect(speakCount, 1);
  });

  testWidgets('cache miss highlight nguyên word theo callback range', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(
          card: _boardingPassCard,
          onSpeak: () {},
          activeWordStart: 0,
          activeWordEnd: 8,
        ),
      ),
    );

    expect(_colorOf(tester, 'board'), AppColors.accent);
    expect(_colorOf(tester, 'ing'), AppColors.accent);
    expect(_colorOf(tester, 'pass'), isNot(AppColors.accent));
  });

  testWidgets('cache hit chỉ highlight segment active từ catalog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(
          card: _boardingPassCard,
          onSpeak: () {},
          activeWordStart: 0,
          activeWordEnd: 8,
          activeSegmentPosition: 1,
        ),
      ),
    );

    expect(_colorOf(tester, 'board'), isNot(AppColors.accent));
    expect(_colorOf(tester, 'ing'), AppColors.accent);
    expect(_colorOf(tester, 'pass'), isNot(AppColors.accent));
  });
}

const _boardingPassCard = StudyCard(
  id: 8,
  term: 'boarding pass',
  definition: 'thẻ lên máy bay',
  language: 'en',
  phonetic: '/ˈbɔːr.dɪŋ pæs/',
  exampleSentence: 'Please have your boarding pass ready.',
  pronunciationSegments: [
    PronunciationSegment(
      position: 0,
      start: 0,
      end: 5,
      text: 'board',
      ipa: 'bɔːr',
      stress: PronunciationStress.primary,
      timingWeight: 2,
    ),
    PronunciationSegment(
      position: 1,
      start: 5,
      end: 8,
      text: 'ing',
      ipa: 'dɪŋ',
      stress: PronunciationStress.none,
      timingWeight: 1,
    ),
    PronunciationSegment(
      position: 2,
      start: 9,
      end: 13,
      text: 'pass',
      ipa: 'pæs',
      stress: PronunciationStress.primary,
      timingWeight: 2,
    ),
  ],
);
