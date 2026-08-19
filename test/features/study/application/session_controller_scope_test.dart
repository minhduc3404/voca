import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/application/session_controller.dart';
import 'package:voca_app/features/study/domain/progress_repository.dart';
import 'package:voca_app/features/study/domain/study_card.dart';
import 'package:voca_app/features/study/domain/study_scope.dart';
import 'package:voca_app/features/study/domain/word_progress.dart';

/// Trả thẻ theo scope được yêu cầu + ghi lại scope đã nhận, để kiểm tra
/// `SessionController` truyền đúng scope xuống repository.
class _ScopeAwareRepository implements ProgressRepository {
  _ScopeAwareRepository(this.cardsByScope);

  final Map<StudyScope, List<StudyCard>> cardsByScope;
  final List<StudyScope> receivedScopes = [];

  @override
  Future<List<StudyCard>> getDueCards(
    DateTime now, {
    StudyScope scope = const StudyScope.all(),
  }) async {
    receivedScopes.add(scope);
    return cardsByScope[scope] ?? const [];
  }

  @override
  Future<WordProgress> getProgress(int cardId) async =>
      WordProgress.initial(cardId: cardId, now: DateTime(2026, 1, 15));

  @override
  Future<void> recordAnswer(WordProgress progress) async {}
}

StudyCard _card(int id, String term) => StudyCard(
  id: id,
  term: term,
  definition: '$term (nghĩa)',
  language: 'en',
  phonetic: '/$term/',
  exampleSentence: 'This is $term.',
);

void main() {
  late _ScopeAwareRepository repository;

  setUp(() {
    repository = _ScopeAwareRepository({
      const StudyScope.all(): [_card(1, 'visa'), _card(2, 'serendipity')],
      const StudyScope.topic('travel'): [_card(1, 'visa')],
      const StudyScope.manual(): [_card(2, 'serendipity')],
    });
  });

  test('mặc định: dùng StudyScope.all', () async {
    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionControllerProvider.future);

    expect(repository.receivedScopes, [const StudyScope.all()]);
    expect(state.dueCards.map((c) => c.id), [1, 2]);
  });

  test('override studyScopeProvider = topic → chỉ thẻ của chủ đề đó', () async {
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(repository),
        studyScopeProvider.overrideWithValue(const StudyScope.topic('travel')),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionControllerProvider.future);

    expect(repository.receivedScopes, [const StudyScope.topic('travel')]);
    expect(state.dueCards.map((c) => c.id), [1]);
    expect(state.total, 1);
  });

  test('override studyScopeProvider = manual → chỉ thẻ tự thêm', () async {
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(repository),
        studyScopeProvider.overrideWithValue(const StudyScope.manual()),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionControllerProvider.future);

    expect(repository.receivedScopes, [const StudyScope.manual()]);
    expect(state.dueCards.map((c) => c.id), [2]);
  });

  test('scope không có thẻ nào → phiên rỗng, isCompleted', () async {
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(repository),
        studyScopeProvider.overrideWithValue(const StudyScope.topic('food')),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionControllerProvider.future);

    expect(state.dueCards, isEmpty);
    expect(state.isCompleted, isTrue);
    expect(state.currentProgress, isNull);
  });
}
