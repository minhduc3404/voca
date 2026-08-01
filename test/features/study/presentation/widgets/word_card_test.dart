import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/presentation/widgets/word_card.dart';

/// `_SyllableSpan` áp màu qua `AnimatedDefaultTextStyle` bao ngoài (để có
/// animation lerp màu), không set `style` trực tiếp lên `Text` con — nên
/// phải đọc màu từ đây thay vì `tester.widget<Text>(...).style` (luôn null).
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

    expect(_colorOf(tester, 'forward'), AppColors.accent);
    expect(_colorOf(tester, 'look'), isNot(AppColors.accent));
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

      expect(_colorOf(tester, 'app'), AppColors.accent);
      expect(_colorOf(tester, 'le'), isNot(AppColors.accent));

      // Âm tiết có trọng âm ('app') giữ lâu hơn — đợi qua mốc đó để nhấn
      // chuyển sang âm tiết còn lại.
      await tester.pump(const Duration(milliseconds: 350));

      expect(_colorOf(tester, 'app'), isNot(AppColors.accent));
      expect(_colorOf(tester, 'le'), AppColors.accent);

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

  testWidgets(
    'đổi sang từ mới trong khi vẫn active (speakingWordIndex giữ nguyên) '
    'phải restart cycle âm tiết, không kẹt ở âm tiết đầu của từ mới',
    (tester) async {
      // Card đầu là từ 1 âm tiết (phonetic không có dấu chấm) — nên timer
      // cycle không bao giờ được set (`_scheduleNextChunk` return sớm vì
      // `_chunks.length <= 1`). Đây chính là điều kiện để lộ bug: nếu
      // `didUpdateWidget` không tự restart cycle khi đổi từ lúc đang active,
      // timer sẽ KHÔNG BAO GIỜ được khởi động cho từ nhiều âm tiết kế tiếp.
      const singleSyllableCard = StudyCard(
        id: 3,
        term: 'cat',
        definition: 'con mèo',
        language: 'en',
        phonetic: '/kæt/',
        exampleSentence: 'The cat sleeps.',
      );
      const nextCard = StudyCard(
        id: 4,
        term: 'banana',
        definition: 'quả chuối',
        language: 'en',
        phonetic: '/bəˈnɑː.nə/',
        exampleSentence: 'I like banana.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WordCard(
            card: singleSyllableCard,
            onSpeak: () {},
            speakingWordIndex: 0,
          ),
        ),
      );

      // Đổi thẳng sang card mới trong khi speakingWordIndex vẫn là 0 —
      // mô phỏng đúng tình huống thực tế: từ đầu tiên của card mới cũng
      // active ngay lập tức, `isActive` không có cạnh false->true.
      await tester.pumpWidget(
        MaterialApp(
          home: WordCard(
            card: nextCard,
            onSpeak: () {},
            speakingWordIndex: 0,
          ),
        ),
      );

      // 'banana' (6 ký tự) chia đều theo 2 âm tiết trong phonetic -> "ban" +
      // "ana" (chunk theo chữ cái, không phải theo phiên âm IPA — xem
      // `_splitIntoChunks`).
      expect(find.text('ban'), findsOneWidget);
      expect(_colorOf(tester, 'ban'), AppColors.accent);

      // Đợi qua thời lượng âm tiết đầu — cycle phải chạy tiếp sang âm tiết
      // kế, không được kẹt mãi ở âm tiết đầu của từ mới (bug: nếu cycle
      // không được restart thì "ban" vẫn accent mãi ở đây).
      await tester.pump(const Duration(milliseconds: 350));

      expect(_colorOf(tester, 'ban'), isNot(AppColors.accent));

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'hết âm tiết cuối thì dừng hẳn, không vòng lại âm tiết đầu',
    (tester) async {
      // 'pronunciation' (13 ký tự) + phonetic 5 âm tiết bằng trọng số ->
      // chunk theo chữ cái: "pro" + "nun" + "cia" + "ti" + "on", mỗi âm
      // tiết giữ 220ms (weight đều nhau). Bug cũ: dùng `% length` nên hết
      // "on" (âm tiết cuối) lại vòng về "pro" và lặp lại cả chu kỳ nếu
      // `isActive` (event mức TỪ, không phải mức âm tiết) vẫn còn true lâu
      // hơn tổng thời lượng ước lượng của animation.
      const longWordCard = StudyCard(
        id: 5,
        term: 'pronunciation',
        definition: 'cách phát âm',
        language: 'en',
        phonetic: '/pro.nun.ci.a.tion/',
        exampleSentence: 'Her pronunciation is clear.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WordCard(
            card: longWordCard,
            onSpeak: () {},
            speakingWordIndex: 0,
          ),
        ),
      );

      expect(_colorOf(tester, 'pro'), AppColors.accent);

      // Đi qua hết 4 lượt chuyển (880ms) để tới âm tiết cuối "on".
      await tester.pump(const Duration(milliseconds: 900));
      expect(_colorOf(tester, 'pro'), isNot(AppColors.accent));
      expect(_colorOf(tester, 'on'), AppColors.accent);

      // Đợi thêm lâu hơn hẳn 1 chu kỳ nữa — "isActive" (event mức từ) vẫn
      // true nhưng KHÔNG được vòng lại tô sáng "pro" lần nữa.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(_colorOf(tester, 'pro'), isNot(AppColors.accent));
      expect(_colorOf(tester, 'on'), AppColors.accent);

      await tester.pumpWidget(const SizedBox());
    },
  );

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
    expect(_colorOf(tester, 'res'), AppColors.accent);

    await tester.pump(const Duration(milliseconds: 250));
    expect(_colorOf(tester, 'res'), AppColors.accent);

    await tester.pumpWidget(const SizedBox());
  });
}
