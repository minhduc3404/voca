import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/study/domain/study_stats.dart';

void main() {
  group('computeStreak (quy tắc NGHIÊM — chỉ tính ngày đã ôn)', () {
    test('rỗng → 0', () {
      expect(computeStreak({}, today: '2026-08-03'), 0);
    });

    test('1 ngày = hôm nay → 1', () {
      expect(computeStreak({'2026-08-03'}, today: '2026-08-03'), 1);
    });

    test('1 ngày = hôm qua, hôm nay chưa học → vẫn 1 (chuỗi chưa đứt)', () {
      expect(computeStreak({'2026-08-02'}, today: '2026-08-03'), 1);
    });

    test('1 ngày quá xa (2 ngày trước, hôm nay + hôm qua không học) → 0', () {
      expect(computeStreak({'2026-08-01'}, today: '2026-08-03'), 0);
    });

    test('3 ngày liên tiếp kết thúc hôm nay → 3', () {
      expect(
        computeStreak(
          {'2026-08-01', '2026-08-02', '2026-08-03'},
          today: '2026-08-03',
        ),
        3,
      );
    });

    test('liên tiếp tới hôm qua, hôm nay chưa học → vẫn giữ (không ân hạn, '
        'không tụt vì chưa qua ngày)', () {
      expect(
        computeStreak(
          {'2026-08-01', '2026-08-02'},
          today: '2026-08-03',
        ),
        2,
      );
    });

    test('đứt giữa: học T2,T4,T5 nhưng bỏ T3 → streak chỉ 2 (T4,T5)', () {
      expect(
        computeStreak(
          {'2026-07-28', '2026-07-30', '2026-07-31'}, // T2, T4, T5
          today: '2026-07-31',
        ),
        2,
      );
    });

    test('cuối tháng/đầu tháng: 31-07, 01-08, 02-08 → 3', () {
      expect(
        computeStreak(
          {'2026-07-31', '2026-08-01', '2026-08-02'},
          today: '2026-08-02',
        ),
        3,
      );
    });

    test('năm nhuận: 28-02-2028, 29-02-2028, 01-03-2028 → 3', () {
      expect(
        computeStreak(
          {'2028-02-28', '2028-02-29', '2028-03-01'},
          today: '2028-03-01',
        ),
        3,
      );
    });

    test('today không hợp lệ → 0 (không crash)', () {
      expect(computeStreak({'2026-08-03'}, today: 'không-phải-ngày'), 0);
    });
  });

  group('dateKey', () {
    test('format đúng YYYY-MM-DD local', () {
      expect(dateKey(DateTime(2026, 8, 3)), '2026-08-03');
      expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
