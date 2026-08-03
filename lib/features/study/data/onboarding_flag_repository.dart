import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trạng thái "đã xem onboarding chưa" — cấu hình nhẹ/UI flag,
/// dùng `shared_preferences` (đúng CLAUDE.md §9: không phải dữ liệu domain
/// hay cần migration cấu trúc). Bọc qua abstraction để UI không import
/// `shared_preferences` trực tiếp.
class OnboardingFlagRepository {
  static const _key = 'onboarding_seen_v1';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
