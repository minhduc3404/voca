import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
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

class _FakeTtsService implements TtsService {
  int speakCount = 0;

  @override
  Future<void> speak(String text) async {
    speakCount++;
  }
}

List<StudyCard> _twoCards() => const [
  StudyCard(
    id: 1,
    term: 'apple',
    definition: 'quả táo',
    language: 'en',
    phonetic: '/ˈæp.əl/',
    partOfSpeech: 'noun',
    exampleSentence: 'She ate a red apple.',
  ),
  StudyCard(
    id: 2,
    term: 'banana',
    definition: 'quả chuối',
    language: 'en',
    phonetic: '/bəˈnɑː.nə/',
    partOfSpeech: 'noun',
    exampleSentence: 'He bought a bunch of bananas.',
  ),
];

Widget _wrap({
  required ProgressRepository repository,
  required TtsService tts,
}) {
  return ProviderScope(
    overrides: [
      progressRepositoryProvider.overrideWithValue(repository),
      ttsServiceProvider.overrideWithValue(tts),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MemoScreen(),
    ),
  );
}

void main() {
  testWidgets(
    'Bấm "Đã nhớ" trong lúc đếm ngược → chuyển thẻ ngay (Good)',
    (tester) async {
      final now = DateTime(2026, 1, 15);
      final repository = _InMemoryRepository(_twoCards(), now);
      final tts = _FakeTtsService();

      await tester.pumpWidget(
        _wrap(repository: repository, tts: tts),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('apple'), findsOneWidget);

      await tester.tap(find.text('Đã nhớ'));
      await tester.pump(); // setState(_showSaved = true)
      expect(find.text('Đã lưu!'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700)); // qua transient

      expect(find.text('banana'), findsOneWidget);

      await tester.tap(find.text('Đã nhớ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Đã ôn hết thẻ đến hạn hôm nay'), findsOneWidget);
    },
  );

  testWidgets(
    'Hết 10s không bấm → tự động chuyển thẻ (Again), không cần thao tác',
    (tester) async {
      final now = DateTime(2026, 1, 15);
      final repository = _InMemoryRepository(_twoCards(), now);
      final tts = _FakeTtsService();

      await tester.pumpWidget(
        _wrap(repository: repository, tts: tts),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('apple'), findsOneWidget);

      // Không bấm gì — để timer tự chạy hết 10s.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump(); // setState(_showSaved = true) từ timer callback
      expect(find.text('Đã lưu!'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('banana'), findsOneWidget);
      // 2 lần auto-speak (giây 2 và 6) đã chạy cho thẻ "apple".
      expect(tts.speakCount, 2);
    },
  );

  testWidgets('Auto-speak gọi TTS ở giây 2 và giây 6', (tester) async {
    final now = DateTime(2026, 1, 15);
    final repository = _InMemoryRepository(_twoCards(), now);
    final tts = _FakeTtsService();

    await tester.pumpWidget(_wrap(repository: repository, tts: tts));
    await tester.pump();
    await tester.pump();

    expect(tts.speakCount, 0);

    await tester.pump(const Duration(seconds: 3));
    expect(tts.speakCount, 1);

    await tester.pump(const Duration(seconds: 4));
    expect(tts.speakCount, 2);

    // Dọn timer còn lại (auto-advance ở giây 10) để test kết thúc sạch.
    await tester.pump(const Duration(seconds: 4));
  });
}
