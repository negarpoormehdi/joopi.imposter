import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color darkPurple = Color(0xFF7E22CE);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color pinkPurple = Color(0xFFC026D3);
  static const Color bgDark = Color(0xFF0F0A1F);
  static const Color cardBg = Color(0xFF1A1030);
  static const Color cardBgLight = Color(0xFF241545);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFC4B5FD);
  static const Color textMuted = Color(0xFFA78BFA);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color pink = Color(0xFFEC4899);
  static const Color blue = Color(0xFF3B82F6);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      fontFamily: 'Vazirmatn',
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: pinkPurple,
        surface: cardBg,
      ),
    );
  }
}
