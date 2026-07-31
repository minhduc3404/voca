import 'package:wakelock_plus/wakelock_plus.dart';

/// Giữ/thả màn hình sáng. Interface tách riêng để test override được —
/// plugin cần platform channel không có trong `flutter test`.
abstract class WakelockService {
  Future<void> enable();
  Future<void> disable();
}

class WakelockPlusService implements WakelockService {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
