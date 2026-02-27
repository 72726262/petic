import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LocaleCubit — persists and toggles app language (ar/en)
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar'));

  static const _key = 'app_locale';

  /// Load saved locale from SharedPreferences
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'en') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('ar'));
    }
  }

  /// Toggle between Arabic and English
  Future<void> toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.languageCode == 'ar') {
      emit(const Locale('en'));
      await prefs.setString(_key, 'en');
    } else {
      emit(const Locale('ar'));
      await prefs.setString(_key, 'ar');
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}
