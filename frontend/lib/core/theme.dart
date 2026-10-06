import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Colors of the validated mock-ups (docs/maquettes).
abstract final class AppColors {
  static const accent = Color(0xFF1F5E4B);
  static const accentLight = Color(0xFFE6F0EC);
  static const background = Color(0xFFFAFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1B1E22);
  static const textSecondary = Color(0xFF5B6168);
  static const border = Color(0xFFE4E4DF);
  static const borderStrong = Color(0xFFD5D6D0);
  static const chipBackground = Color(0xFFEDEDE8);
  static const star = Color(0xFFD99A2B);
  static const starOutline = Color(0xFFB7791F);
  static const error = Color(0xFF8A2A1B);
  static const errorBackground = Color(0xFFFCEDEA);

  /// Backgrounds of generated covers, all dark enough for white text.
  static const covers = [
    Color(0xFF2F4858),
    Color(0xFF8C3B2E),
    Color(0xFF3E6B48),
    Color(0xFF2D5D7B),
    Color(0xFF6B4E8C),
    Color(0xFF7A2E4A),
    Color(0xFF4F5D2F),
    Color(0xFF8A5F1C),
    Color(0xFF33475B),
  ];
}

/// Bricolage Grotesque for titles (title styles up to titleSmall), Instrument Sans for text.
/// Tests pass [googleFonts] false: the fonts are downloaded at runtime.
ThemeData buildTheme({bool googleFonts = true}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.text,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  final body = (googleFonts ? GoogleFonts.instrumentSansTextTheme(base.textTheme) : base.textTheme).apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );
  TextStyle? title(TextStyle? style) {
    final bold = style?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text);
    return googleFonts ? GoogleFonts.bricolageGrotesque(textStyle: bold) : bold;
  }

  final textTheme = body.copyWith(
    displayLarge: title(body.displayLarge),
    displayMedium: title(body.displayMedium),
    displaySmall: title(body.displaySmall),
    headlineLarge: title(body.headlineLarge),
    headlineMedium: title(body.headlineMedium),
    headlineSmall: title(body.headlineSmall),
    titleLarge: title(body.titleLarge),
    titleMedium: title(body.titleMedium),
    titleSmall: title(body.titleSmall),
  );
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(44, 48), shape: rounded),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        shape: rounded,
        side: const BorderSide(color: AppColors.borderStrong),
        foregroundColor: AppColors.text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent,
      side: const BorderSide(color: AppColors.borderStrong),
      shape: const StadiumBorder(),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accentLight,
    ),
    dividerColor: AppColors.border,
  );
}
