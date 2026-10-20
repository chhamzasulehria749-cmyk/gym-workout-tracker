import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8C7CFF);
  static const Color primaryDark = Color(0xFF4E46C7);

  static const Color green = Color(0xFF00A896);
  static const Color orange = Color(0xFFFF9F1C);
  static const Color red = Color(0xFFE85D75);
  static const Color blue = Color(0xFF4D96FF);

  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color darkBackground = Color(0xFF0D0C14);

  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF171621);

  static const Color textDark = Color(0xFF17151F);
  static const Color textLight = Color(0xFFF7F7FA);

  static const Color textGrey = Color(0xFF777580);
  static const Color darkTextGrey = Color(0xFF9A98A8);

  static const Color border = Color(0xFFE8E7EF);
  static const Color darkBorder = Color(0xFF292735);

  // ============================================================
  // OLD / EXISTING TEXT STYLES
  // These keep your existing screens working.
  // ============================================================

  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textDark,
    letterSpacing: -0.8,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textGrey,
  );

  static const TextStyle smallBody = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textGrey,
  );

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: primaryLight,
          surface: lightCard,
          error: red,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: lightBackground,

      cardColor: lightCard,

      dividerColor: border,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),

      // --------------------------------------------------------
      // TEXT THEME
      // --------------------------------------------------------
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: -0.7,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: textDark),
        bodyMedium: TextStyle(fontSize: 13, color: textGrey),
        bodySmall: TextStyle(fontSize: 11, color: textGrey),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textGrey,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textGrey,
        ),
      ),

      // --------------------------------------------------------
      // INPUT FIELDS
      // --------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),

        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        hintStyle: const TextStyle(color: textGrey, fontSize: 13),

        prefixIconColor: primary,
      ),

      // --------------------------------------------------------
      // ELEVATED BUTTON
      // --------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // OUTLINED BUTTON
      // --------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // TEXT BUTTON
      // --------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // CARD
      // --------------------------------------------------------
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border, width: 0.6),
        ),
      ),

      // --------------------------------------------------------
      // DIALOG
      // --------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: textDark,
        ),
        contentTextStyle: const TextStyle(fontSize: 13, color: textGrey),
      ),

      // --------------------------------------------------------
      // SNACKBAR
      // --------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF24222F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --------------------------------------------------------
      // NAVIGATION BAR
      // --------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        height: 72,

        indicatorColor: primary.withValues(alpha: 0.12),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            );
          }

          return const TextStyle(
            color: textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 23);
          }

          return const IconThemeData(color: textGrey, size: 22);
        }),
      ),

      // --------------------------------------------------------
      // FAB
      // --------------------------------------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // --------------------------------------------------------
      // PROGRESS INDICATOR
      // --------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),

      // --------------------------------------------------------
      // SWITCH
      // --------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }

          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.35);
          }

          return Colors.grey.shade200;
        }),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: primaryLight,
          secondary: primary,
          surface: darkCard,
          error: red,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: darkBackground,

      cardColor: darkCard,

      dividerColor: darkBorder,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),

      // --------------------------------------------------------
      // TEXT THEME
      // --------------------------------------------------------
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: textLight,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: textLight,
          letterSpacing: -0.7,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          color: textLight,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textLight,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: textLight),
        bodyMedium: TextStyle(fontSize: 13, color: darkTextGrey),
        bodySmall: TextStyle(fontSize: 11, color: darkTextGrey),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextGrey,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: darkTextGrey,
        ),
      ),

      // --------------------------------------------------------
      // INPUT FIELDS
      // --------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: const Color(0xFF1C1B27),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: darkBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),

        labelStyle: const TextStyle(
          color: darkTextGrey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        hintStyle: const TextStyle(color: darkTextGrey, fontSize: 13),

        prefixIconColor: primaryLight,
      ),

      // --------------------------------------------------------
      // ELEVATED BUTTON
      // --------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // OUTLINED BUTTON
      // --------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: primaryLight, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // TEXT BUTTON
      // --------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),

      // --------------------------------------------------------
      // CARD
      // --------------------------------------------------------
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkBorder, width: 0.6),
        ),
      ),

      // --------------------------------------------------------
      // DIALOG
      // --------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: textLight,
        ),
        contentTextStyle: const TextStyle(fontSize: 13, color: darkTextGrey),
      ),

      // --------------------------------------------------------
      // SNACKBAR
      // --------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF24222F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --------------------------------------------------------
      // NAVIGATION BAR
      // --------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        height: 72,

        indicatorColor: primary.withValues(alpha: 0.18),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            );
          }

          return const TextStyle(
            color: darkTextGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryLight, size: 23);
          }

          return const IconThemeData(color: darkTextGrey, size: 22);
        }),
      ),

      // --------------------------------------------------------
      // FAB
      // --------------------------------------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // --------------------------------------------------------
      // PROGRESS INDICATOR
      // --------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryLight,
      ),

      // --------------------------------------------------------
      // SWITCH
      // --------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }

          return const Color(0xFF777580);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.35);
          }

          return const Color(0xFF292735);
        }),
      ),
    );
  }
}
