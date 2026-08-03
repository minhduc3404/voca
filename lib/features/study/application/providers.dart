import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/drift_progress_repository.dart';
import '../data/drift_study_log_repository.dart';
import '../data/drift_study_stats_repository.dart';
import '../data/drift_tts_word_timing_cache_repository.dart';
import '../data/onboarding_flag_repository.dart';
import '../data/tts/factory_tts_service.dart';
import '../data/tts_settings_repository.dart';
import '../data/wakelock_service.dart';
import '../domain/progress_repository.dart';
import '../domain/study_log_repository.dart';
import '../domain/study_stats_repository.dart';
import '../domain/tts_service.dart';
import '../domain/tts_word_timing_cache_repository.dart';

/// Điểm nối duy nhất giữa application và implementation cụ thể của
/// [ProgressRepository]. Chuyển từ `FakeProgressRepository` sang
/// `DriftProgressRepository` ở Phase 2 — chỉ sửa file này, không đụng
/// `domain/`, `session_controller.dart`, hay `presentation/`.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftProgressRepository(db);
});

final studyLogRepositoryProvider = Provider<StudyLogRepository>((ref) {
  return DriftStudyLogRepository(ref.watch(appDatabaseProvider));
});

final studyStatsRepositoryProvider = Provider<StudyStatsRepository>((ref) {
  return DriftStudyStatsRepository(ref.watch(appDatabaseProvider));
});

final onboardingFlagRepositoryProvider = Provider<OnboardingFlagRepository>(
  (ref) => OnboardingFlagRepository(),
);

/// Đã xem onboarding chưa — dùng cho màn đầu tiên (app.dart `_Root`).
final onboardingSeenProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingFlagRepositoryProvider).hasSeenOnboarding();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = FactoryTtsService().create();
  ref.onDispose(service.dispose);
  return service;
});

final ttsWordTimingCacheRepositoryProvider =
    Provider<TtsWordTimingCacheRepository>((ref) {
      return DriftTtsWordTimingCacheRepository(ref.watch(appDatabaseProvider));
    });

final wakelockServiceProvider = Provider<WakelockService>((ref) {
  return WakelockPlusService();
});

final ttsSettingsRepositoryProvider = Provider<TtsSettingsRepository>((ref) {
  return SharedPreferencesTtsSettingsRepository();
});

/// Danh sách giọng tiếng Anh thiết bị hỗ trợ — tải một lần, dùng cho màn
/// cài đặt TTS chọn giọng. Có timeout vì đây là gọi ra plugin/engine TTS
/// ngoài — một số thiết bị/trình duyệt không hỗ trợ hoặc phản hồi chậm,
/// không được để màn cài đặt treo mãi vì việc này.
final availableVoicesProvider = FutureProvider<List<TtsVoice>>((ref) {
  return ref
      .watch(ttsServiceProvider)
      .getVoices()
      .timeout(const Duration(seconds: 5), onTimeout: () => const []);
});
