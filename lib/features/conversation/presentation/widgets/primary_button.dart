import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_theme.dart';

/// Nút chính (primary CTA) của conversation — theo pattern `RememberButton`
/// của study: height 56, accent + elevation/shadow accent để nổi trên dark
/// theme. Text style kế thừa global `filledButtonTheme` của [AppTheme.dark]
/// (w800 / 16 / letterSpacing .8 / radius 18).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

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
        child: Text(label),
      ),
    );
  }
}
