import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Joggly's design tokens: restrained neutrals + one confident accent (Indigo),
/// set Outfit for type, craft bar: Strava / Linear / Revolut / Airbnb.
class AppColors {
  AppColors._();

  static const accent = Color(0xFF4F46E5);
  static const accentDark = Color(0xFF3730A3);
  static const accentTint = Color(0xFFEEF0FD);

  static const ground = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF16181D);
  static const inkSecondary = Color(0xFF61657A);
  static const divider = Color(0xFFE7E7EC);

  static const success = Color(0xFF16A34A);
  static const successTint = Color(0xFFE9F7EE);
  static const danger = Color(0xFFDC2626);
  static const dangerTint = Color(0xFFFCEAEA);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 320);

  /// The app's one authored motion grammar: exponential ease-out from an
  /// already-visible default. Reused everywhere instead of ad-hoc curves.
  static const curve = Curves.easeOutCubic;
}

ThemeData buildAppTheme() {
  // Built directly (not from GoogleFonts.outfitTextTheme()): in this Flutter release that
  // helper returns material_ui's TextTheme, not the flutter/material one ThemeData expects.
  // GoogleFonts.outfit() itself returns a plain, unforked TextStyle, so it's unaffected.
  final textTheme = TextTheme(
    headlineMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: AppColors.ink,
      height: 1.15,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: AppColors.ink,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyLarge: GoogleFonts.outfit(fontSize: 16, color: AppColors.ink, height: 1.4),
    bodyMedium: GoogleFonts.outfit(fontSize: 14.5, color: AppColors.ink, height: 1.4),
    labelLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.inkSecondary,
      letterSpacing: 0.1,
    ),
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    primary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.ground,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.ground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accentTint,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.accent : AppColors.inkSecondary,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: GoogleFonts.outfit(color: AppColors.inkSecondary, fontSize: 14.5),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : AppColors.divider,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColors.accentTint : AppColors.ground,
      ),
    ),
  );
}
