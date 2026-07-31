import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/data/tts_service.dart';
import 'package:voca_app/features/study/data/wakelock_service.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';
import 'package:voca_app/features/study/presentation/memo_screen.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

/// Test cho control ⏮/⏸/⏭ bổ sung theo mockup Claude Design "Voca Memo" —
/// ⏸ tạm dừng đếm ngược/tự phát của chế độ rảnh tay; ⏮/⏭ đổi tốc độ đoạn
/// đang chạy. Không đổi domain/SRS — chỉ ảnh hưởng nhịp phát UI, xem
/// `docs/tasks/2026-07-31-memo-screen-visual-redesign.md`.
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

  @override
  Future<List<TtsVoice>> getVoices() async => const [];

  @override
  Future<void> setVoice(TtsVoice voice) async {}

  @override
  Future<void> setSpeechRate(double rate) async {}
}

class _FakeWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
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

Widget _wrap({required ProgressRepository repository, required TtsService tts}) {
  return ProviderScope(
    overrides: [
      progressRepositoryProvider.overrideWithValue(repository),
      ttsServiceProvider.overrideWithValue(tts),
      wakelockServiceProvider.overrideWithValue(_FakeWakelockService()),
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
    'Bấm ⏸ tạm dừng → hết 10s gốc vẫn không tự chuyển thẻ, bấm lại thì tiếp tục',
    (tester) async {
      final now = DateTime(2026, 1, 15);
      final repository = _InMemoryRepository(_twoCards(), now);
      final tts = _FakeTtsService();

      await tester.pumpWidget(_wrap(repository: repository, tts: tts));
      await tester.pump();
      await tester.pump();

      expect(find.text('apple'), findsOneWidget);

      await tester.tap(find.byTooltip('Tạm dừng'));
      await tester.pump();
      expect(find.byTooltip('Tiếp tục'), findsOneWidget);

      // Vượt qua hẳn 10s gốc mà không có gì xảy ra vì đang tạm dừng.
      await tester.pump(const Duration(seconds: 15));
      expect(find.text('apple'), findsOneWidget);
      expect(tts.speakCount, 0);

      await tester.tap(find.byTooltip('Tiếp tục'));
      await tester.pump();

      // Toàn bộ ~10s còn lại kể từ lúc resume.
      await tester.pump(const Duration(seconds: 11));
      expect(find.text('banana'), findsOneWidget);
    },
  );

  testWidgets('Bấm ⏭ tăng tốc độ → chuyển thẻ nhanh hơn 10s mặc định', (
    tester,
  ) async {
    final now = DateTime(2026, 1, 15);
    final repository = _InMemoryRepository(_twoCards(), now);
    final tts = _FakeTtsService();

    await tester.pumpWidget(_wrap(repository: repository, tts: tts));
    await tester.pump();
    await tester.pump();

    expect(find.text('apple'), findsOneWidget);

    // 1.0x -> 1.25x -> 1.5x -> 2.0x (tối đa trong danh sách tốc độ).
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Tăng tốc độ'));
      await tester.pump();
    }

    // Ở 2.0x, đoạn 10s gốc còn 5s — 6s là đủ để tự chuyển thẻ dù mặc định
    // (1.0x) cần tới 10s.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('banana'), findsOneWidget);
  });
}
