import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep navy dark background (from mockup)
  static const Color bgDark       = Color(0xFF0B0F1A);
  static const Color bgCard       = Color(0xFF111827);
  static const Color bgCardLight  = Color(0xFF1A2235);
  static const Color bgCardBorder = Color(0xFF1E2D45);

  // Blue accent (glowing blue from mockup logo & buttons)
  static const Color accentBlue       = Color(0xFF3B82F6);
  static const Color accentBlueDark   = Color(0xFF1D4ED8);
  static const Color accentBlueGlow   = Color(0xFF60A5FA);
  static const Color accentBlueDim    = Color(0xFF1E3A5F);

  // Green (income)
  static const Color green        = Color(0xFF10B981);
  static const Color greenDim     = Color(0xFF064E3B);

  // Red (expense)
  static const Color red          = Color(0xFFEF4444);
  static const Color redDim       = Color(0xFF7F1D1D);

  // Yellow/Gold (savings %)
  static const Color yellow       = Color(0xFFF59E0B);
  static const Color yellowDim    = Color(0xFF78350F);

  // Purple (loans)
  static const Color purple       = Color(0xFF8B5CF6);
  static const Color purpleDim    = Color(0xFF4C1D95);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF475569);

  // Bottom nav
  static const Color navBg        = Color(0xFF0F1628);
  static const Color navSelected  = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.green,
        surface: AppColors.bgCard,
        background: AppColors.bgDark,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.bgCardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bgCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bgCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dividerColor: AppColors.bgCardBorder,
    );
  }

  static ThemeData get lightTheme => darkTheme; // Force dark only per design
}
