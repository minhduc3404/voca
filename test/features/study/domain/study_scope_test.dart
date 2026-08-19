import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/domain/study_scope.dart';

void main() {
  group('StudyScope', () {
    test('all: kind = all, không có topicId', () {
      const scope = StudyScope.all();
      expect(scope.kind, StudyScopeKind.all);
      expect(scope.topicId, isNull);
    });

    test('topic: giữ topicId', () {
      const scope = StudyScope.topic('travel');
      expect(scope.kind, StudyScopeKind.topic);
      expect(scope.topicId, 'travel');
    });

    test('manual: kind = manual, không có topicId', () {
      const scope = StudyScope.manual();
      expect(scope.kind, StudyScopeKind.manual);
      expect(scope.topicId, isNull);
    });

    test('value equality — dùng được làm khoá override provider', () {
      expect(const StudyScope.all(), const StudyScope.all());
      expect(const StudyScope.manual(), const StudyScope.manual());
      expect(const StudyScope.topic('travel'), const StudyScope.topic('travel'));

      expect(
        const StudyScope.all().hashCode,
        const StudyScope.all().hashCode,
      );
      expect(
        const StudyScope.topic('travel').hashCode,
        const StudyScope.topic('travel').hashCode,
      );
    });

    test('các scope khác nhau không bằng nhau', () {
      expect(const StudyScope.all(), isNot(const StudyScope.manual()));
      expect(const StudyScope.manual(), isNot(const StudyScope.topic('travel')));
      expect(
        const StudyScope.topic('travel'),
        isNot(const StudyScope.topic('food')),
      );
    });
  });
}
