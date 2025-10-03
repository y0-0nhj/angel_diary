import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static Locale _currentLocale = const Locale('ko', '');
  
  // 싱글톤 인스턴스
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  static Locale get currentLocale => _currentLocale;

  static Future<void> setLanguage(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    _instance.notifyListeners(); // 인스턴스의 notifyListeners 호출
  }

  /*
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _currentLocale = Locale(languageCode, '');
    }
  }

*/
  // 저장된 언어를 불러오는 초기화 함수 (앱 시작 시 호출)
  static Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString(_languageKey);
    if (savedLangCode != null) {
      _currentLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == savedLangCode,
        orElse: () => const Locale('ko'), // 기본값
      );
    }
    _instance.notifyListeners(); // 인스턴스의 notifyListeners 호출
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
