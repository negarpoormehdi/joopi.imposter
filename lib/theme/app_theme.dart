import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color darkPurple = Color(0xFF7E22CE);
  static const Color bgPurple = Color(0xFF3B0764);
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

  static const double sectionPadding = 20;
  static const double sectionSpacing = 20;

  static const double playerIconBoxSize = 56;
  static const double playerIconBoxRadius = 18;
  static const double playerIconSize = 28;

  static const double titleFontSize = 19;
  static const double subtitleFontSize = 13;
  static const double badgeFontSize = 13;
  static const double chipFontSize = 15;
  static const double inputFontSize = 14;
  static const double buttonFontSize = 15;
  static const double bigNumberFontSize = 32;
  static const double smallNumberFontSize = 20;
  static const double largeTitleFontSize = 22;
  static const double largeSubtitleFontSize = 14;

  static const FontWeight titleWeight = FontWeight.w900;
  static const FontWeight subtitleWeight = FontWeight.w500;
  static const FontWeight badgeWeight = FontWeight.w800;
  static const FontWeight chipWeight = FontWeight.w700;
  static const FontWeight inputWeight = FontWeight.w600;
  static const FontWeight buttonWeight = FontWeight.w800;

  static const double chipDotSize = 12;
  static const double chipCloseIconSize = 20;
  static const double chipSpacing = 10;
  static const double chipHorizontalPadding = 16;
  static const double chipVerticalPadding = 10;

  static const double addButtonIconSize = 22;
  static const double addButtonHorizontalPadding = 24;
  static const double addButtonVerticalPadding = 12;
  static const double addButtonRadius = 22;
  static const double addRowPadding = 5;
  static const double addRowRadius = 26;

  static const double numberBoxRadius = 38;
  static const double numberBoxHorizontalPadding = 24;
  static const double numberBoxVerticalPadding = 20;

  static const double controlButtonSize = 56;
  static const double controlButtonRadius = 20;
  static const double controlIconSize = 28;

  static const double countBadgeRadius = 999;
  static const double countBadgeHorizontalPadding = 14;
  static const double countBadgeVerticalPadding = 8;

  static const String fontFamily = 'IranSans';

  static TextTheme _buildTextTheme(TextTheme base) {
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(fontFamily: fontFamily),
          displayMedium: base.displayMedium?.copyWith(fontFamily: fontFamily),
          displaySmall: base.displaySmall?.copyWith(fontFamily: fontFamily),
          headlineLarge: base.headlineLarge?.copyWith(fontFamily: fontFamily),
          headlineMedium: base.headlineMedium?.copyWith(fontFamily: fontFamily),
          headlineSmall: base.headlineSmall?.copyWith(fontFamily: fontFamily),
          titleLarge: base.titleLarge?.copyWith(fontFamily: fontFamily),
          titleMedium: base.titleMedium?.copyWith(fontFamily: fontFamily),
          titleSmall: base.titleSmall?.copyWith(fontFamily: fontFamily),
          bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamily),
          bodyMedium: base.bodyMedium?.copyWith(fontFamily: fontFamily),
          bodySmall: base.bodySmall?.copyWith(fontFamily: fontFamily),
          labelLarge: base.labelLarge?.copyWith(fontFamily: fontFamily),
          labelMedium: base.labelMedium?.copyWith(fontFamily: fontFamily),
          labelSmall: base.labelSmall?.copyWith(fontFamily: fontFamily),
        )
        .apply(bodyColor: textPrimary, displayColor: textPrimary);
  }

  static ThemeData darkTheme() {
    final baseTextTheme = _buildTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bgDark,
      textTheme: baseTextTheme,
      primaryTextTheme: baseTextTheme,
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: pinkPurple,
        surface: cardBg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        toolbarTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          foregroundColor: lightPurple,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          foregroundColor: textPrimary,
          side: const BorderSide(color: primaryPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: TextStyle(
          fontFamily: fontFamily,
          color: textMuted,
          fontSize: 12,
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          color: red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBgLight,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: textPrimary,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        iconColor: lightPurple,
      ),
      dividerTheme: DividerThemeData(
        color: primaryPurple.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textMuted,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        indicatorColor: primaryPurple.withValues(alpha: 0.3),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: textMuted, size: 24),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardBg,
        selectedIconTheme: const IconThemeData(color: primaryPurple),
        unselectedIconTheme: const IconThemeData(color: textMuted),
        selectedLabelTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: primaryPurple,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cardBgLight,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardBgLight,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: primaryPurple.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: pinkPurple,
        textColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
