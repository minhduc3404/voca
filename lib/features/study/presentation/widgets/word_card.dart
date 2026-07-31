import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../../domain/study_card.dart';

/// Hiển thị toàn bộ nội dung thẻ trên MỘT mặt — chế độ rảnh tay, không cần
/// chạm để lật: phiên âm, term, nghĩa, câu ví dụ hiện cùng lúc, theo layout
/// mockup Claude Design "Voca Memo - Memo Screen" (phonetic mono nhỏ → term
/// lớn đậm → nghĩa xanh → ví dụ in nghiêng mờ, căn giữa).
class WordCard extends StatelessWidget {
  const WordCard({required this.card, required this.onSpeak, super.key});

  final StudyCard card;

  /// Gọi khi bấm nút loa thủ công. `memo_screen.dart` còn tự động phát âm
  /// theo thời gian (2s, 6s) — đây là để nghe lại theo yêu cầu riêng.
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                card.partOfSpeech == null
                    ? card.phonetic
                    : '${card.phonetic} · ${card.partOfSpeech}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  letterSpacing: .5,
                  color: AppColors.phonetic,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const Key('word-card-speak-button'),
                icon: AppIcon('volume-up', size: 18, color: AppColors.phonetic),
                visualDensity: VisualDensity.compact,
                tooltip: 'Nghe phát âm',
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.term,
            style: textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          Text(
            card.definition,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              '"${card.exampleSentence}"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
                color: AppColors.textFainter,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
