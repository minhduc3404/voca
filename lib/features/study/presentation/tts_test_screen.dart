import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tts_test_controller.dart';

/// Màn test/diagnostics TTS: tải model (có progress), phát âm thử, và xem log
/// độc lập ngay trên màn hình — tách khỏi luồng học để cô lập lỗi TTS.
class TtsTestScreen extends ConsumerStatefulWidget {
  const TtsTestScreen({super.key});

  @override
  ConsumerState<TtsTestScreen> createState() => _TtsTestScreenState();
}

class _TtsTestScreenState extends ConsumerState<TtsTestScreen> {
  final _textController = TextEditingController(text: 'reservation');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ttsTestControllerProvider);
    final controller = ref.read(ttsTestControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Test'),
        actions: [
          IconButton(
            tooltip: 'Xoá log',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: controller.clearLogs,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Model', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.downloading) ...[
              LinearProgressIndicator(
                value: state.totalBytes > 0 ? state.progress : null,
              ),
              const SizedBox(height: 4),
              Text(
                state.totalBytes > 0
                    ? '${(state.progress * 100).toStringAsFixed(1)}%  '
                          '(${state.downloadedBytes}/${state.totalBytes})'
                    : 'Đang tải…',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.downloading
                        ? null
                        : controller.ensureModel,
                    icon: const Icon(Icons.download),
                    label: const Text('Tải model'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.downloading
                        ? null
                        : controller.deleteModel,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xoá model'),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Phát âm', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Text cần đọc',
              ),
              onSubmitted: controller.speak,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Tốc độ'),
                Expanded(
                  child: Slider(
                    value: state.speed.clamp(0.5, 2.0),
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    label: '${state.speed.toStringAsFixed(2)}×',
                    onChanged: controller.setSpeed,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${state.speed.toStringAsFixed(2)}×',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: state.speaking
                  ? null
                  : () => controller.speak(_textController.text),
              icon: state.speaking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(state.speaking ? 'Đang phát…' : 'Speak'),
            ),
            const Divider(height: 32),
            Text('Log', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: state.logs.isEmpty
                    ? Text(
                        'Chưa có log. Bấm "Tải model" hoặc "Speak".',
                        style: theme.textTheme.bodySmall,
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: state.logs.length,
                        itemBuilder: (context, index) {
                          final line =
                              state.logs[state.logs.length - 1 - index];
                          return Text(
                            line,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
