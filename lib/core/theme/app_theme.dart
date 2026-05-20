import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// KaamKaar's premium design system.
/// Supports both light and dark (true black AMOLED) modes and RTL/Urdu typography.
class AppTheme {
  // === Brand Colors ===
  static const Color primary = Color(0xFF1A7FE8); // KaamKaar Blue
  static const Color primaryDark = Color(0xFF4BA3FF); // Lighter blue for dark mode
  static const Color secondary = Color(0xFFFF6B35); // Pakistani Warmth Orange
  static const Color accent = Color(0xFF00C896); // Success Green
  static const Color aiPurple = Color(0xFF7C3AED); // AI Reasoning Purple
  static const Color errorRed = Color(0xFFEF4444);

  // === Light Mode Colors ===
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F1117);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // === Dark Mode Colors ===
  static const Color backgroundDark = Color(0xFF000000); // True AMOLED black
  static const Color surfaceDark = Color(0xFF111111); // Card surface
  static const Color surface2Dark = Color(0xFF1C1C1E); // Elevated surface
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color dividerDark = Color(0xFF2C2C2E);

  // === Gradients ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A7FE8), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ================= LIGHT THEME =================
  static ThemeData lightTheme(bool isUrdu) {
    final textTheme = isUrdu 
        ? _buildUrduTextTheme(textPrimaryLight, textSecondaryLight)
        : _buildEnglishTextTheme(textPrimaryLight, textSecondaryLight);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: errorRed,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F2F5),
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEEEEEE), thickness: 1),
    );
  }

  // ================= DARK THEME =================
  static ThemeData darkTheme(bool isUrdu) {
    final textTheme = isUrdu 
        ? _buildUrduTextTheme(textPrimaryDark, textSecondaryDark)
        : _buildEnglishTextTheme(textPrimaryDark, textSecondaryDark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: secondary,
        error: errorRed,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerDark, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2Dark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: dividerDark, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryDark, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.black),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primaryDark, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: primaryDark,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2Dark,
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: textPrimaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerDark, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: dividerDark, thickness: 0.5),
    );
  }

  // === English TextTheme ===
  static TextTheme _buildEnglishTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 36, fontWeight: FontWeight.w800).copyWith(color: primary, letterSpacing: -0.5),
      displayMedium: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 28, fontWeight: FontWeight.bold).copyWith(color: primary),
      titleLarge: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 20, fontWeight: FontWeight.bold).copyWith(color: primary),
      titleMedium: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w600).copyWith(color: primary),
      titleSmall: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w600).copyWith(color: primary),
      bodyLarge: const TextStyle(fontFamily: 'Inter', fontSize: 16).copyWith(color: primary, height: 1.5),
      bodyMedium: const TextStyle(fontFamily: 'Inter', fontSize: 14).copyWith(color: secondary, height: 1.5),
      bodySmall: const TextStyle(fontFamily: 'Inter', fontSize: 12).copyWith(color: secondary, height: 1.4),
      labelLarge: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w600).copyWith(color: primary),
      labelSmall: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500).copyWith(color: primary),
    );
  }

  // === Urdu TextTheme ===
  // Increased sizes for Nastaliq readability
  static TextTheme _buildUrduTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 42).copyWith(color: primary),
      displayMedium: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 34).copyWith(color: primary),
      titleLarge: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 24).copyWith(color: primary),
      titleMedium: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 20).copyWith(color: primary),
      titleSmall: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 18).copyWith(color: primary),
      bodyLarge: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 20).copyWith(color: primary, height: 1.8),
      bodyMedium: const TextStyle(fontFamily: 'NotoNastaliqUrdu', fontSize: 16).copyWith(color: secondary, height: 1.8),
      bodySmall: const TextStyle(fontFamily: 'NotoNastaliqUrdu', fontSize: 14).copyWith(color: secondary, height: 1.6),
      labelLarge: const TextStyle(fontFamily: 'JameelNooriNastaleeq', fontSize: 18).copyWith(color: primary),
      labelSmall: const TextStyle(fontFamily: 'NotoNastaliqUrdu', fontSize: 12).copyWith(color: primary),
    );
  }

  /// Returns JetBrains Mono text style for log/code rendering
  static TextStyle monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Adaptive color — returns correct value based on current theme brightness
  static Color adaptiveColor(BuildContext context, {required Color light, required Color dark}) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// Quick surface color accessor
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dividerDark : const Color(0xFFEEEEEE);
}
