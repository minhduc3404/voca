import 'package:flutter/material.dart';

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
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Đã nhớ'),
          if (previewLabel != null)
            Text(previewLabel!, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
