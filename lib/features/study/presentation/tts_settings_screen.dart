import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../application/tts_settings_controller.dart';

/// Chỉnh tốc độ đọc + chọn giọng TTS. Không import `data/` trực tiếp —
/// chỉ đọc field qua giá trị đã suy type từ provider (giống pattern
/// `WakelockService`), giữ đúng ranh giới presentation/data.
class TtsSettingsScreen extends ConsumerWidget {
  const TtsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(ttsSettingsControllerProvider);
    final voicesAsync = ref.watch(availableVoicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt phát âm')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Lỗi tải cài đặt: $error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tốc độ đọc',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: settings.speechRate.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              divisions: 30,
              label: '${settings.speechRate.toStringAsFixed(2)}×',
              onChanged: (value) => ref
                  .read(ttsSettingsControllerProvider.notifier)
                  .updateSpeechRate(value),
            ),
            const SizedBox(height: 24),
            Text('Giọng đọc', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            voicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text('Không tải được danh sách giọng: $error'),
              data: (voices) => voices.isEmpty
                  ? const Text(
                      'Thiết bị không hỗ trợ chọn giọng — dùng giọng mặc định.',
                    )
                  : RadioGroup<String>(
                      groupValue: settings.voiceName,
                      onChanged: (name) {
                        final voice = voices.firstWhere(
                          (voice) => voice.name == name,
                        );
                        ref
                            .read(ttsSettingsControllerProvider.notifier)
                            .updateVoice(voice);
                      },
                      child: Column(
                        children: [
                          for (final voice in voices)
                            RadioListTile<String>(
                              title: Text(voice.name),
                              subtitle: Text(voice.locale),
                              value: voice.name,
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
