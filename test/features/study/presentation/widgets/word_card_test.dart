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

  testWidgets(
    'từ đơn đang active tách theo âm tiết trong phonetic, chạy lần lượt',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WordCard(card: card, onSpeak: () {}, speakingWordIndex: 0),
        ),
      );

      // 'apple' + '/ˈæp.əl/' -> 2 âm tiết (ˈæp, əl) -> tách "app" + "le".
      expect(find.text('apple'), findsNothing);
      expect(find.text('app'), findsOneWidget);
      expect(find.text('le'), findsOneWidget);

      final firstSyllable = tester.widget<Text>(find.text('app'));
      expect(firstSyllable.style?.color, AppColors.accent);
      final secondSyllable = tester.widget<Text>(find.text('le'));
      expect(secondSyllable.style?.color, isNot(AppColors.accent));

      // Âm tiết có trọng âm ('app') giữ lâu hơn — đợi qua mốc đó để nhấn
      // chuyển sang âm tiết còn lại.
      await tester.pump(const Duration(milliseconds: 350));

      final firstSyllableLater = tester.widget<Text>(find.text('app'));
      expect(firstSyllableLater.style?.color, isNot(AppColors.accent));
      final secondSyllableLater = tester.widget<Text>(find.text('le'));
      expect(secondSyllableLater.style?.color, AppColors.accent);

      // Bỏ hẳn widget để dispose Timer đang cycle — tránh "pending timer"
      // còn sót lại khi test kết thúc.
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('từ đơn không active thì hiện liền, không tách âm tiết', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: WordCard(card: card, onSpeak: () {})),
    );

    expect(find.text('apple'), findsOneWidget);
    expect(find.text('app'), findsNothing);
    expect(find.text('le'), findsNothing);
  });

  testWidgets('nhận đúng trọng âm khi dấu ˈ nằm giữa đoạn IPA (không ở đầu)', (
    tester,
  ) async {
    // Dữ liệu thật (seed_data.dart): 'resilient' -> '/rɪˈzɪl.i.ənt/' — dấu
    // 'ˈ' nằm SAU 'rɪ', không ở đầu đoạn "rɪˈzɪl". Âm tiết đầu vẫn phải được
    // tính là trọng âm chính (giữ highlight lâu hơn ~330ms thay vì 220ms).
    const resilientCard = StudyCard(
      id: 4,
      term: 'resilient',
      definition: 'kiên cường',
      language: 'en',
      phonetic: '/rɪˈzɪl.i.ənt/',
      exampleSentence: 'She is resilient.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WordCard(
          card: resilientCard,
          onSpeak: () {},
          speakingWordIndex: 0,
        ),
      ),
    );

    // 'resilient' (9 ký tự) chia đều 3 đoạn -> "res" + "ili" + "ent".
    expect(find.text('res'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('res')).style?.color,
      AppColors.accent,
    );

    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester.widget<Text>(find.text('res')).style?.color,
      AppColors.accent,
    );

    await tester.pumpWidget(const SizedBox());
  });
}
