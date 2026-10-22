// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Colori della bacheca estrazioni: fondo chiaro, titolo blu, fascia arancione,
/// nomi ruota arancioni, numeri blu, palline blu con cifra gialla.
class AppColors {
  const AppColors._();

  static const navy = Color(0xFF1B4E8C);
  static const numberBlue = Color(0xFF2F6EAD);
  static const banner = Color(0xFFF0A01A);
  static const wheel = Color(0xFFD47812);
  static const ball = Color(0xFF1E4C96);
  static const ballText = Color(0xFFF6D34A);
  static const ballGold = Color(0xFFF2C230);
  static const gold = Color(0xFFC8962E);
  static const rowAlt = Color(0xFFF3F5F8);
  static const line = Color(0xFFE3E6EC);
  static const ink = Color(0xFF1A1C1E);

  /// Tenuti per i punti che citano ancora il viola (splash storico).
  static const purple = Color(0xFF1B4E8C);
  static const purpleDeep = navy;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? const Color(0xFF8EB4E8) : AppColors.navy,
      onPrimary: dark ? const Color(0xFF0E1624) : Colors.white,
      secondary: AppColors.banner,
      onSecondary: Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: dark ? const Color(0xFF162033) : Colors.white,
      onSurface: dark ? const Color(0xFFE7EDF5) : AppColors.ink,
    );
    final radius = BorderRadius.circular(8);
    final title = TextStyle(
      fontFamily: 'serif',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: scheme.primary,
      height: 1.1,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0E1624) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: title,
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: dark ? const Color(0xFF2A3A52) : AppColors.line)),
      ),
      dividerColor: dark ? const Color(0xFF2A3A52) : AppColors.line,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.55));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6));
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurface.withValues(alpha: 0.55)),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.banner),
          foregroundColor: WidgetStatePropertyAll(Colors.white),
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: dark ? const Color(0xFF2A3A52) : AppColors.line),
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.banner),
    );
  }
}
