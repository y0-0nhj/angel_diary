import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 전역 캘린더 데이터 관리자
/// 
/// 캘린더 데이터와 소망 데이터의 저장, 로드, 삭제를 담당합니다.
class CalendarDataManager {
  static final Map<String, Map<String, dynamic>> _calendarData = {};
  static final Map<String, List<Map<String, dynamic>>> _persistentWishes = 
      {}; // 소망은 지속적으로 유지
  static const String _calendarKey = 'calendar_data';
  static const String _wishesKey = 'wishes_data';

  /// 특정 날짜의 데이터를 반환합니다.
  static Map<String, dynamic>? getDayData(String dateString) {
    return _calendarData[dateString];
  }

  /// 특정 날짜의 데이터를 저장합니다.
  static Future<void> saveDayData(
    String dateString,
    Map<String, dynamic> dayData,
  ) async {
    _calendarData[dateString] = dayData;
    await _saveCalendarToStorage();
  }

  /// 일기 내용을 저장합니다.
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

  /// 특정 날짜의 일기를 반환합니다.
  static String? getDiary(String dateString) {
    return _calendarData[dateString]?['diary'] as String?;
  }

  /// 소망 전용 저장 메서드
  static Future<void> saveWishes(
    String dateString,
    List<Map<String, dynamic>> wishes,
  ) async {
    _persistentWishes[dateString] = List<Map<String, dynamic>>.from(wishes);
    await _saveWishesToStorage();
  }

  /// 특정 날짜의 소망 목록을 반환합니다.
  static List<Map<String, dynamic>> getWishes(String dateString) {
    return _persistentWishes[dateString] ?? [];
  }

  /// 소망이 설정되어 있는지 확인합니다.
  static bool hasWishes(String dateString) {
    return _persistentWishes.containsKey(dateString) &&
        _persistentWishes[dateString]!.isNotEmpty;
  }

  /// 모든 캘린더 데이터를 반환합니다.
  static Map<String, Map<String, dynamic>> get allData => _calendarData;

  /// SharedPreferences에 캘린더 데이터 저장
  static Future<void> _saveCalendarToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calendarJson = jsonEncode(_calendarData);
      await prefs.setString(_calendarKey, calendarJson);
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
  }

  /// SharedPreferences에 소망 데이터 저장
  static Future<void> _saveWishesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishesJson = jsonEncode(_persistentWishes);
      await prefs.setString(_wishesKey, wishesJson);
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
  }

  /// SharedPreferences에서 캘린더 데이터 로드
  static Future<void> loadCalendarFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 캘린더 데이터 로드
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

      // 소망 데이터 로드
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
      // 에러 처리 (로깅 등)
    }
  }

  /// 모든 데이터 삭제
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_calendarKey);
      await prefs.remove(_wishesKey);
      _calendarData.clear();
      _persistentWishes.clear();
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
  }
}
