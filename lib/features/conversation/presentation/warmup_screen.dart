import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_theme.dart';

import '../domain/conversation_script.dart';
import 'conversation_play_screen.dart';
import 'widgets/primary_button.dart';

/// Warm-up: review nhanh từ vựng mục tiêu trước khi vào hội thoại.
class WarmUpScreen extends StatelessWidget {
  const WarmUpScreen({required this.script, super.key});

  final ConversationScript script;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          script.titleVi,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ôn nhanh từ vựng',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Những từ này sẽ xuất hiện trong hội thoại:',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textFaint,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: script.targetVocab.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final vocab = script.targetVocab[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      title: Text(
                        vocab.term,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        vocab.senseVi,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textFaint,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Bắt đầu',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConversationPlayScreen(script: script),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
