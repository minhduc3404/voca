import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/core/widgets/async_state_view.dart';

import '../application/providers.dart';
import '../domain/conversation_script.dart';
import 'warmup_screen.dart';

/// Danh mục Giao tiếp — danh sách script (mock ở MVP, sau này từ Firebase).
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scriptsAsync = ref.watch(conversationListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Luyện nói',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: scriptsAsync.when(
        loading: () => const AsyncStateView(
          isLoading: true,
          errorMessage: null,
          onRetry: _noop,
          loadingLabel: 'Đang tải...',
          child: SizedBox.shrink(),
        ),
        error: (error, stackTrace) => AsyncStateView(
          isLoading: false,
          errorMessage: 'Không tải được danh sách kịch bản: $error',
          onRetry: () => ref
              .read(conversationListControllerProvider.notifier)
              .reload(),
          child: const SizedBox.shrink(),
        ),
        data: (scripts) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: scripts.length,
          itemBuilder: (context, index) {
            final script = scripts[index];
            return _ScriptCard(script: script);
          },
        ),
      ),
    );
  }
}

void _noop() {}

/// Card script theo chuẩn app: `Material(color: AppColors.controlBg)`
/// + `InkWell` + icon box 44x44 accent (như _ConversationCard/_TopicCard).
class _ScriptCard extends StatelessWidget {
  const _ScriptCard({required this.script});

  final ConversationScript script;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.controlBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WarmUpScreen(script: script)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppIcon('chat', size: 22, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      script.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      script.descriptionVi,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textFaint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Tag(label: '${script.estimatedMinutes} phút'),
                        _Tag(label: script.difficulty),
                        for (final vocab in script.targetVocab)
                          _Tag(label: vocab.term),
                      ],
                    ),
                  ],
                ),
              ),
              AppIcon('skip-next', size: 20, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tag nhỏ theo chuẩn app: nền `AppColors.controlBg` (thay vì
/// `surfaceContainerHighest` của M3) để khớp dark theme cố định.
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.controlBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textFaint,
        ),
      ),
    );
  }
}
