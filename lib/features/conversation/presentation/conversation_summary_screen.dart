import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../domain/conversation_script.dart';
import 'widgets/primary_button.dart';

/// Kết thúc buổi luyện — ôn lại toàn bộ từ vựng mục tiêu của script.
/// (MVP: chỉ hiển thị. SRS link + lưu session để Phase 2.)
class ConversationSummaryScreen extends StatelessWidget {
  const ConversationSummaryScreen({required this.script, super.key});

  final ConversationScript script;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Kết quả buổi luyện',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppIcon('check-circle', size: 48, color: AppColors.accent),
              const SizedBox(height: 12),
              Text(
                'Hoàn thành!',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn đã nghe hết đoạn hội thoại. Ôn lại ${script.targetVocab.length} từ vựng trong bài:',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textFaint,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                        child: const AppIcon(
                          'check-circle',
                          size: 20,
                          color: AppColors.accent,
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
                label: 'Xong',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
