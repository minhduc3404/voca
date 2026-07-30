import 'package:flutter/material.dart';

/// 4 nút chọn rating. Không phụ thuộc domain — chỉ phát callback theo tên
/// nút, việc map sang [StudyRating] là việc của caller (memo_screen.dart).
class ControlBar extends StatelessWidget {
  const ControlBar({
    required this.onAgain,
    required this.onHard,
    required this.onGood,
    required this.onEasy,
    super.key,
  });

  final VoidCallback onAgain;
  final VoidCallback onHard;
  final VoidCallback onGood;
  final VoidCallback onEasy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RatingButton(label: 'Again', color: Colors.red, onPressed: onAgain),
        _RatingButton(
          label: 'Hard',
          color: Colors.orange,
          onPressed: onHard,
        ),
        _RatingButton(label: 'Good', color: Colors.green, onPressed: onGood),
        _RatingButton(label: 'Easy', color: Colors.blue, onPressed: onEasy),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
