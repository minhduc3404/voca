import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tts_service.dart';
import '../data/tts_settings_repository.dart';
import 'providers.dart';

/// Điều phối cấu hình TTS: nạp lựa chọn đã lưu, áp dụng vào [TtsService],
/// và ghi lại mỗi khi người dùng đổi tốc độ/giọng. Không chứa logic UI —
/// `tts_settings_screen.dart` chỉ gọi các method dưới đây.
class TtsSettingsController extends AsyncNotifier<TtsSettings> {
  @override
  Future<TtsSettings> build() async {
    final settings = await ref.watch(ttsSettingsRepositoryProvider).load();
    // Không await — áp dụng vào TtsService là side-effect ra plugin ngoài,
    // không được chặn màn hình cài đặt (cùng nguyên tắc "fire-and-forget"
    // đã dùng cho `speak()` ở memo_screen.dart: engine TTS có thể chưa sẵn
    // sàng/chậm khởi tạo, không liên quan tới việc đọc/hiện lựa chọn đã lưu).
    unawaited(_apply(settings));
    return settings;
  }

  Future<void> _apply(TtsSettings settings) async {
    final tts = ref.read(ttsServiceProvider);
    await tts.setSpeechRate(settings.speechRate);
    final voiceName = settings.voiceName;
    final voiceLocale = settings.voiceLocale;
    if (voiceName != null && voiceLocale != null) {
      await tts.setVoice(TtsVoice(name: voiceName, locale: voiceLocale));
    }
  }

  Future<void> updateSpeechRate(double rate) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(speechRate: rate));
  }

  Future<void> updateVoice(TtsVoice voice) async {
    final current = state.value;
    if (current == null) return;
    await _persist(
      current.copyWith(voiceName: voice.name, voiceLocale: voice.locale),
    );
  }

  Future<void> _persist(TtsSettings updated) async {
    unawaited(_apply(updated));
    await ref.read(ttsSettingsRepositoryProvider).save(updated);
    state = AsyncData(updated);
  }
}

final ttsSettingsControllerProvider =
    AsyncNotifierProvider<TtsSettingsController, TtsSettings>(
      TtsSettingsController.new,
    );
