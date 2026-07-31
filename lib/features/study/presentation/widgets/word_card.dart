import 'package:flutter/material.dart';

import '../../domain/study_card.dart';

/// Hiển thị toàn bộ nội dung thẻ trên MỘT mặt — chế độ rảnh tay, không cần
/// chạm để lật: term, phiên âm, từ loại, nghĩa, câu ví dụ hiện cùng lúc.
class WordCard extends StatelessWidget {
  const WordCard({required this.card, required this.onSpeak, super.key});

  final StudyCard card;

  /// Gọi khi bấm nút loa thủ công. `memo_screen.dart` còn tự động phát âm
  /// theo thời gian (2s, 6s) — đây là để nghe lại theo yêu cầu riêng.
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.term,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.partOfSpeech == null
                        ? card.phonetic
                        : '${card.phonetic} · ${card.partOfSpeech}',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    tooltip: 'Nghe phát âm',
                    onPressed: onSpeak,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                card.definition,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                card.exampleSentence,
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
