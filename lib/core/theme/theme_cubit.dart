import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:employee_portal/core/utils/app_constants.dart';

/// ThemeCubit — persists and toggles app theme (light/dark)
class ThemeCubit extends Cubit<ThemeMode> {
  // Default to light theme on first run
  ThemeCubit() : super(ThemeMode.light);

  static const _key = AppConstants.prefThemeMode;

  /// Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else if (saved == 'light') {
      emit(ThemeMode.light);
    } else {
      // Default to light if no saved preference
      emit(ThemeMode.light);
    }
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
      await prefs.setString(_key, 'light');
    } else {
      emit(ThemeMode.dark);
      await prefs.setString(_key, 'dark');
    }
  }

  /// Set a specific theme
  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDark => state == ThemeMode.dark;
}
