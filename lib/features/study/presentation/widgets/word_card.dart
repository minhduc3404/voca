import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../../domain/study_card.dart';

/// Hiển thị toàn bộ nội dung thẻ trên MỘT mặt — chế độ rảnh tay, không cần
/// chạm để lật: phiên âm, term, nghĩa, câu ví dụ hiện cùng lúc, theo layout
/// mockup Claude Design "Voca Memo - Memo Screen" (phonetic mono nhỏ → term
/// lớn đậm → nghĩa xanh → ví dụ in nghiêng mờ, căn giữa).
class WordCard extends StatelessWidget {
  const WordCard({
    required this.card,
    required this.onSpeak,
    this.speakingWordIndex,
    super.key,
  });

  final StudyCard card;

  /// Gọi khi bấm nút loa thủ công. `memo_screen.dart` còn tự động phát âm
  /// theo thời gian (2s, 6s) — đây là để nghe lại theo yêu cầu riêng.
  final VoidCallback onSpeak;

  /// Chỉ số từ (tách theo khoảng trắng trong `card.term`) đang được TTS đọc,
  /// `null` nếu không có từ nào đang đọc. Đây là `int?` thuần — widget không
  /// biết gì về TTS/riverpod, chỉ nhận số để tô sáng đúng từ (dumb widget,
  /// giống pattern `onSpeak`).
  final int? speakingWordIndex;

  /// Tách `term` theo khoảng trắng — điểm ngắt tự nhiên sẵn có trong từ
  /// vựng, không cần thêm dữ liệu nào để biết ranh giới từng từ.
  List<String> get _termWords =>
      RegExp(r'\S+').allMatches(card.term).map((m) => m.group(0)!).toList();

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
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final entry in _termWords.indexed)
                _AnimatedTermWord(
                  text: entry.$2,
                  isActive: entry.$1 == speakingWordIndex,
                  style: textTheme.displaySmall,
                ),
            ],
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

/// Một từ trong `term` — phóng nhẹ + đổi màu accent khi đang được TTS đọc.
class _AnimatedTermWord extends StatelessWidget {
  const _AnimatedTermWord({
    required this.text,
    required this.isActive,
    required this.style,
  });

  final String text;
  final bool isActive;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.08 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        style: isActive
            ? (style ?? const TextStyle()).copyWith(color: AppColors.accent)
            : style ?? const TextStyle(),
        child: Text(text),
      ),
    );
  }
}
