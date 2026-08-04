import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../domain/conversation_script.dart';
import 'widgets/primary_button.dart';

/// Kết thúc buổi luyện — liệt kê từ vựng đã dùng trong hội thoại.
/// (MVP: chỉ hiển thị. SRS link + lưu session để Phase 2.)
class ConversationSummaryScreen extends StatelessWidget {
  const ConversationSummaryScreen({
    required this.script,
    required this.usedTargetWords,
    super.key,
  });

  final ConversationScript script;
  final Set<String> usedTargetWords;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final usedVocab = script.targetVocab
        .where((v) => usedTargetWords.contains(v.term))
        .toList();

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
                'Bạn đã dùng ${usedVocab.length}/${script.targetVocab.length} từ mới trong hội thoại.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textFaint,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: usedVocab.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final vocab = usedVocab[index];
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
