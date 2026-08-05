import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyberpunk color palette — neon glows against void black
class CyberpunkColors {
  CyberpunkColors._();

  static const Color background = Color(0xFF0a0a0f);
  static const Color surface = Color(0xFF1a1a2e);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color primary = Color(0xFF00fff5);       // Neon cyan
  static const Color secondary = Color(0xFFff00ff);      // Neon magenta
  static const Color accent = Color(0xFFf5ff00);         // Electric yellow
  static const Color error = Color(0xFFff3131);          // Glitch red
  static const Color textPrimary = Color(0xFFe0e0ff);    // Cool white
  static const Color textSecondary = Color(0xFF8888aa);   // Muted lavender
  static const Color cardBorder = Color(0xFF2a2a4a);
  static const Color streakFire = Color(0xFFff6b35);     // Streak orange

  // Priority colors
  static const Color priorityLow = Color(0xFF00fff5);
  static const Color priorityMedium = Color(0xFFf5ff00);
  static const Color priorityHigh = Color(0xFFff3131);

  // Contribution graph intensity
  static const Color contribNone = Color(0xFF1a1a2e);
  static const Color contribLow = Color(0xFF004d4d);
  static const Color contribMedium = Color(0xFF008080);
  static const Color contribHigh = Color(0xFF00cccc);
  static const Color contribMax = Color(0xFF00fff5);
}

class CyberpunkTheme {
  CyberpunkTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberpunkColors.background,
      primaryColor: CyberpunkColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: CyberpunkColors.primary,
        secondary: CyberpunkColors.secondary,
        surface: CyberpunkColors.surface,
        error: CyberpunkColors.error,
        onPrimary: CyberpunkColors.background,
        onSecondary: CyberpunkColors.background,
        onSurface: CyberpunkColors.textPrimary,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: CyberpunkColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberpunkColors.cardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CyberpunkColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: CyberpunkColors.primary,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: CyberpunkColors.primary),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 1.5,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 1,
        ),
        titleLarge: GoogleFonts.shareTechMono(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.textPrimary,
        ),
        titleMedium: GoogleFonts.shareTechMono(
          fontSize: 16,
          color: CyberpunkColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.shareTechMono(
          fontSize: 16,
          color: CyberpunkColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.shareTechMono(
          fontSize: 14,
          color: CyberpunkColors.textSecondary,
        ),
        bodySmall: GoogleFonts.shareTechMono(
          fontSize: 12,
          color: CyberpunkColors.textSecondary,
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.primary,
          letterSpacing: 1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberpunkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberpunkColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberpunkColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberpunkColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.shareTechMono(color: CyberpunkColors.textSecondary),
        hintStyle: GoogleFonts.shareTechMono(color: CyberpunkColors.textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CyberpunkColors.primary,
        foregroundColor: CyberpunkColors.background,
        elevation: 8,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CyberpunkColors.surface,
        selectedItemColor: CyberpunkColors.primary,
        unselectedItemColor: CyberpunkColors.textSecondary,
        selectedLabelStyle: GoogleFonts.orbitron(fontSize: 10, letterSpacing: 1),
        unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 10),
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CyberpunkColors.surfaceLight,
        contentTextStyle: GoogleFonts.shareTechMono(color: CyberpunkColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CyberpunkColors.primary, width: 1),
        ),
      ),
    );
  }
}

/// Neon glow box decoration for cards/containers
BoxDecoration neonGlowDecoration({
  Color glowColor = CyberpunkColors.primary,
  double blurRadius = 12,
  double borderRadius = 16,
}) {
  return BoxDecoration(
    color: CyberpunkColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: glowColor.withValues(alpha: 0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: glowColor.withValues(alpha: 0.15),
        blurRadius: blurRadius,
        spreadRadius: 1,
      ),
    ],
  );
}
