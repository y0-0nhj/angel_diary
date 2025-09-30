import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarManager {
  static final Map<String, Map<String, dynamic>> _calendarData = {};
  static final Map<String, List<Map<String, dynamic>>> _persistentWishes = {};
  static const String _calendarKey = 'calendar_data';
  static const String _wishesKey = 'wishes_data';

  static Map<String, dynamic>? getDayData(String dateString) {
    return _calendarData[dateString];
  }

  static Future<void> saveDayData(
    String dateString,
    Map<String, dynamic> dayData,
  ) async {
    _calendarData[dateString] = dayData;
    await _saveCalendarToStorage();
  }

  static Future<void> saveDiary(String dateString, String diaryContent) async {
    if (_calendarData[dateString] == null) {
      _calendarData[dateString] = {
        'wishes': <Map<String, dynamic>>[],
        'goals': <Map<String, dynamic>>[],
        'gratitudes': <Map<String, dynamic>>[],
        'diary': '',
      };
    }
    _calendarData[dateString]!['diary'] = diaryContent;
    await _saveCalendarToStorage();
  }

  static String? getDiary(String dateString) {
    return _calendarData[dateString]?['diary'] as String?;
  }

  static Future<void> saveWishes(
    String dateString,
    List<Map<String, dynamic>> wishes,
  ) async {
    _persistentWishes[dateString] = List<Map<String, dynamic>>.from(wishes);
    await _saveWishesToStorage();
  }

  static List<Map<String, dynamic>> getWishes(String dateString) {
    return _persistentWishes[dateString] ?? [];
  }

  static bool hasWishes(String dateString) {
    return _persistentWishes.containsKey(dateString) &&
        _persistentWishes[dateString]!.isNotEmpty;
  }

  static Future<void> _saveCalendarToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calendarJson = jsonEncode(_calendarData);
      await prefs.setString(_calendarKey, calendarJson);
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> _saveWishesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishesJson = jsonEncode(_persistentWishes);
      await prefs.setString(_wishesKey, wishesJson);
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final calendarJson = prefs.getString(_calendarKey);
      if (calendarJson != null) {
        final calendarData = Map<String, Map<String, dynamic>>.from(
          jsonDecode(calendarJson).map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ),
        );
        _calendarData.clear();
        _calendarData.addAll(calendarData);
      }

      final wishesJson = prefs.getString(_wishesKey);
      if (wishesJson != null) {
        final wishesData = Map<String, List<Map<String, dynamic>>>.from(
          jsonDecode(wishesJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(
                (value as List).map((item) => Map<String, dynamic>.from(item)),
              ),
            ),
          ),
        );
        _persistentWishes.clear();
        _persistentWishes.addAll(wishesData);
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_calendarKey);
      await prefs.remove(_wishesKey);
      _calendarData.clear();
      _persistentWishes.clear();
    } catch (e) {
      // Handle error
    }
  }
}
