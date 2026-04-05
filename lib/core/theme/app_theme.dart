import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0D0B1F); // Absolute Void
  static const Color surface = Color(0xFF0D0B1F);
  static const Color surfaceContainer = Color(0xFF14122D);
  static const Color surfaceContainerHigh = Color(0xFF1B183B);
  static const Color surfaceContainerHighest = Color(0xFF221F49);
  static const Color surfaceContainerLow = Color(0xFF0A0818);
  static const Color surfaceContainerLowest = Color(0xFF050410);
  
  static const Color chronosPurple = Color(0xFF7357C5); // Glass Hourglass
  static const Color chronosPurpleGlow = Color(0xFF9E89FF); // Vibrant Ion
  

  static const Color orange = Color(0xFFF59E0B); // Neural Power
  static const Color orangeGlow = Color(0xFFFFB347);
  
  static const Color onSurface = Color(0xFFE0E0FF);
  static const Color onSurfaceVariant = Color(0xFFA6A6C7);
  
  static const Color outline = Color(0xFF3F3D56);
  static const Color outlineVariant = Color(0x4D3F3D56); // 30% Opacity
  
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [chronosPurple, chronosPurpleGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static Color glass(double opacity) => surfaceVariant.withValues(alpha: opacity);
  static const Color surfaceVariant = Color(0xFF221F49);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.chronosPurpleGlow,
        primaryContainer: AppColors.chronosPurple,
        secondary: AppColors.chronosPurple,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Color(0xFF1B0061),
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5, // The Technical precision look
          color: AppColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
