import 'package:flutter/material.dart';

/// Design tokens từ mockup Claude Design "Voca Memo - Memo Screen" — màu
/// không map sạch vào role chuẩn của `ColorScheme`/`TextTheme` (vd nghĩa
/// tiếng Việt dùng xanh riêng, ví dụ dùng trắng mờ theo alpha cụ thể) nên
/// giữ làm hằng số riêng thay vì gượng ép vào `ColorScheme`.
class AppColors {
  const AppColors._();

  static const background = Color(0xFF10131A);
  static const accent = Color(0xFF6C8CFF);
  static const meaning = Color(0xFF9FB0D6);

  static const textPrimary = Colors.white;
  static final Color textFaint = Colors.white.withValues(alpha: .5);
  static final Color textFainter = Colors.white.withValues(alpha: .4);
  static final Color textDot = Colors.white.withValues(alpha: .28);

  static final Color controlBg = Colors.white.withValues(alpha: .07);
  static final Color controlBgDisabled = Colors.white.withValues(alpha: .035);
  static final Color controlIcon = Colors.white.withValues(alpha: .82);
  static final Color controlIconDisabled = Colors.white.withValues(alpha: .3);
  static final Color progressTrack = Colors.white.withValues(alpha: .10);
  static final Color phonetic = accent.withValues(alpha: .85);
  static final Color accentGlow = accent.withValues(alpha: .14);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // Bundled TTF (ADR-006) — không phụ thuộc Google Fonts CDN lúc runtime.
      fontFamily: 'NotoSans',
    );
  }

  /// Dark theme cố định theo URD của mockup "Voca Memo" (không phải biến thể
  /// của seed color mặc định) — nền `#10131A`, accent `#6C8CFF`.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      surface: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'NotoSans',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        // Term của thẻ từ ("morning").
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 46,
          height: 1.05,
          letterSpacing: -.5,
          color: AppColors.textPrimary,
        ),
        // Nghĩa tiếng Việt ("buổi sáng").
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 23,
          height: 1.3,
          color: AppColors.meaning,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: .8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
