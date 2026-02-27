import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// Complete ThemeData for light and dark modes
class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          surface: AppColors.surfaceLight,
          surfaceContainerHighest: AppColors.surfaceVariantLight,
          error: AppColors.error,
          errorContainer: AppColors.errorLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurfaceLight,
          onSurfaceVariant: AppColors.onSurfaceVariantLight,
          onError: Colors.white,
          outline: AppColors.dividerLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: AppTypography.buildTextTheme(),

        // ─── AppBar ─────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.titleLarge
              .copyWith(color: AppColors.onSurfaceLight),
          iconTheme:
              const IconThemeData(color: AppColors.onSurfaceLight, size: 24),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),

        // ─── Card ───────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorderRadius,
          ),
          margin: const EdgeInsets.all(0),
        ),

        // ─── Input Decoration ───────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantLight,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide:
                const BorderSide(color: AppColors.dividerLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
        ),

        // ─── Elevated Button ────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBorderRadius,
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // ─── Text Button ────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBorderRadius,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ─── Outlined Button ────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBorderRadius,
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // ─── Chip ───────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariantLight,
          selectedColor: AppColors.primaryContainer,
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.fullBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),

        // ─── Divider ────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
          space: 0,
        ),

        // ─── Icon ───────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariantLight,
          size: 24,
        ),

        // ─── Bottom Nav ──────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariantLight,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),

        // ─── Tab Bar ─────────────────────────────────────────────────
        tabBarTheme: TabBarThemeData(
          labelStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
          unselectedLabelStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.dividerLight,
        ),

        // ─── Floating Action Button ──────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorderRadius,
          ),
        ),

        // ─── Dialog ──────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlBorderRadius,
          ),
          titleTextStyle: AppTypography.titleLarge
              .copyWith(color: AppColors.onSurfaceLight),
        ),

        // ─── Snack Bar ───────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.onSurfaceLight,
          contentTextStyle:
              AppTypography.bodyMedium.copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius,
          ),
        ),
      );

  // ─── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          primaryContainer: Color(0xFF1A3A6E),
          secondary: AppColors.secondary,
          secondaryContainer: Color(0xFF0A4A49),
          surface: AppColors.surfaceDark,
          surfaceContainerHighest: AppColors.surfaceVariantDark,
          error: AppColors.error,
          errorContainer: Color(0xFF5C1A1A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurfaceDark,
          onSurfaceVariant: AppColors.onSurfaceVariantDark,
          onError: Colors.white,
          outline: AppColors.dividerDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: AppTypography.buildTextTheme(isDark: true),

        // ─── AppBar ─────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle:
              AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceDark),
          iconTheme:
              const IconThemeData(color: AppColors.onSurfaceDark, size: 24),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // ─── Card ───────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorderRadius,
          ),
        ),

        // ─── Input ──────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide:
                const BorderSide(color: AppColors.dividerDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorderRadius,
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantDark,
          ),
        ),

        // ─── Elevated Button ────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBorderRadius,
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // ─── Divider ────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 0,
        ),

        // ─── Dialog ──────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlBorderRadius,
          ),
        ),

        // ─── Snack Bar ───────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceVariantDark,
          contentTextStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceDark),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius,
          ),
        ),

        // ─── Bottom Nav ──────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.onSurfaceVariantDark,
          elevation: 0,
        ),

        // ─── Tab Bar ─────────────────────────────────────────────────
        tabBarTheme: TabBarThemeData(
          labelStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.primaryLight,
          ),
          unselectedLabelStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.onSurfaceVariantDark,
          ),
          indicatorColor: AppColors.primaryLight,
          dividerColor: AppColors.dividerDark,
        ),
      );
}
