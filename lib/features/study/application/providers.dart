import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/drift_progress_repository.dart';
import '../data/drift_study_log_repository.dart';
import '../data/drift_study_stats_repository.dart';
import '../data/drift_tts_audio_cache_repository.dart';
import '../data/drift_tts_word_timing_cache_repository.dart';
import '../data/onboarding_flag_repository.dart';
import '../data/tts/factory_tts_service.dart';
import '../data/tts/tts_audio_handler.dart';
import '../data/tts/tts_model_manager.dart';
import '../data/tts_settings_repository.dart';
import '../data/wakelock_service.dart';
import '../domain/progress_repository.dart';
import '../domain/study_log_repository.dart';
import '../domain/study_scope.dart';
import '../domain/study_stats_repository.dart';
import '../domain/tts_audio_cache_repository.dart';
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

/// Phạm vi từ vựng của phiên học hiện tại. Mặc định [StudyScope.all] — ôn
/// toàn bộ bộ học như trước.
///
/// `MemoScreen` bọc chính nó trong một `ProviderScope` và override provider
/// này để mở phiên học giới hạn (một chủ đề, hoặc riêng từ tự thêm) mà
/// không cần đổi chữ ký `sessionControllerProvider` — mỗi scope là một
/// container con nên hai phiên khác scope không dùng chung state.
final studyScopeProvider = Provider<StudyScope>((ref) {
  return const StudyScope.all();
});

/// Đã xem onboarding chưa — dùng cho màn đầu tiên (app.dart `_Root`).
final onboardingSeenProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingFlagRepositoryProvider).hasSeenOnboarding();
});

/// Quản lý tải/giải nén model TTS. Singleton dùng chung giữa warm-up lúc mở
/// app ([ttsModelWarmupProvider]) và [ttsServiceProvider] — chung một
/// instance để cơ chế gộp lời gọi trong `ensureModel` chỉ tải MỘT lần.
final ttsModelManagerProvider = Provider<TtsModelManager>((ref) {
  return TtsModelManager();
});

/// Cache audio TTS đã synth, bền vững qua kill app — xem
/// `DriftTtsAudioCacheRepository`.
final ttsAudioCacheRepositoryProvider = Provider<TtsAudioCacheRepository>((
  ref,
) {
  return DriftTtsAudioCacheRepository(ref.watch(appDatabaseProvider));
});

/// Handler `audio_service` cho phát nền + lock-screen control — override
/// bằng instance thật trong `bootstrap()` (Android/iOS, sau khi
/// `AudioService.init()` chạy trước `runApp()`). `null` trên web (không hỗ
/// trợ background/lock-screen) — `ttsServiceProvider` fallback về impl TTS
/// thuần khi đó.
final audioHandlerProvider = Provider<TtsAudioHandler?>((ref) => null);

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = FactoryTtsService(
    modelManager: ref.watch(ttsModelManagerProvider),
    audioCache: ref.watch(ttsAudioCacheRepositoryProvider),
  ).create();
  ref.onDispose(service.dispose);

  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) return service;

  handler.attachInner(service);
  ref.onDispose(handler.dispose);
  return handler;
});

/// Chuẩn bị TTS ngay khi mở app (đọc provider này lúc bootstrap để kích
/// hoạt): tải model + dựng engine trong isolate nền, để lượt `speak()` đầu
/// không phải chờ. Nền, không chặn UI; lỗi được giữ trong AsyncValue —
/// lần `speak()` sau sẽ thử lại qua cùng `warmUp`/`ensureModel`.
final ttsModelWarmupProvider = FutureProvider<void>((ref) async {
  await ref.watch(ttsServiceProvider).warmUp();
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
