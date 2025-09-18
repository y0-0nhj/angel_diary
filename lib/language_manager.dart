import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'selected_language';
  static Locale _currentLocale = const Locale('ko', '');

  static Locale get currentLocale => _currentLocale;

  static Future<void> setLanguage(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _currentLocale = Locale(languageCode, '');
    }
  }

  static List<Locale> get supportedLocales => const [
    Locale('ko', ''), // 한국어
    Locale('en', ''), // 영어
    Locale('ja', ''), // 일본어
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return '한국어';
    }
  }
}
