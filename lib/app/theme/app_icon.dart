import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icon Reicon (bộ duotone, vendor thủ công theo ADR-009) — render qua
/// `flutter_svg`, tô 1 màu bằng `ColorFilter` (srcIn) để giữ đúng hiệu ứng
/// 2 tầng opacity gốc của icon duotone dưới `currentColor`.
///
/// `name` là slug kebab-case khớp tên file trong `assets/icons/`.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {this.size = 24, this.color, super.key});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? Colors.white;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
