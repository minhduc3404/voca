import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

/// Nút "Đã nhớ" duy nhất — chế độ rảnh tay: bấm trong lúc đang đếm ngược
/// nghĩa là nhớ được; không bấm kịp thì `memo_screen.dart` tự động coi là
/// chưa nhớ và chuyển thẻ tiếp theo. Không phụ thuộc domain — "dumb
/// widget", caller quyết định hành vi thật.
class RememberButton extends StatelessWidget {
  const RememberButton({required this.onPressed, this.previewLabel, super.key});

  final VoidCallback onPressed;

  /// Nhãn preview interval nếu nhớ (vd "10 phút") — nullable, caller tự
  /// tính từ domain rồi format thành chuỗi hiển thị.
  final String? previewLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          shadowColor: AppColors.accent,
          elevation: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon('check-circle', size: 21, color: Colors.white),
            const SizedBox(width: 9),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Đã nhớ'),
                if (previewLabel != null)
                  Text(previewLabel!, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
