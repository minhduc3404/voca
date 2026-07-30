import 'package:flutter/material.dart';

/// 4 nút chọn rating. Không phụ thuộc domain — chỉ phát callback theo tên
/// nút, việc map sang `StudyRating` là việc của caller (memo_screen.dart).
/// Nhãn preview interval (`XLabel`) là chuỗi hiển thị thuần, caller tự tính
/// từ domain rồi format — widget này không biết SRS là gì.
class ControlBar extends StatelessWidget {
  const ControlBar({
    required this.onAgain,
    required this.onHard,
    required this.onGood,
    required this.onEasy,
    this.againLabel,
    this.hardLabel,
    this.goodLabel,
    this.easyLabel,
    super.key,
  });

  final VoidCallback onAgain;
  final VoidCallback onHard;
  final VoidCallback onGood;
  final VoidCallback onEasy;

  final String? againLabel;
  final String? hardLabel;
  final String? goodLabel;
  final String? easyLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RatingButton(
          label: 'Again',
          previewLabel: againLabel,
          color: Colors.red,
          onPressed: onAgain,
        ),
        _RatingButton(
          label: 'Hard',
          previewLabel: hardLabel,
          color: Colors.orange,
          onPressed: onHard,
        ),
        _RatingButton(
          label: 'Good',
          previewLabel: goodLabel,
          color: Colors.green,
          onPressed: onGood,
        ),
        _RatingButton(
          label: 'Easy',
          previewLabel: easyLabel,
          color: Colors.blue,
          onPressed: onEasy,
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.previewLabel,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String? previewLabel;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (previewLabel != null)
            Text(previewLabel!, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
