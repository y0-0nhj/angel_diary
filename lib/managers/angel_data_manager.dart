import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/angel_data.dart';

/// 전역 천사 데이터 관리자
/// 
/// 천사 데이터의 저장, 로드, 삭제를 담당합니다.
class AngelDataManager {
  static AngelData? _currentAngel;
  static const String _angelKey = 'angel_data';

  /// 현재 천사 데이터를 반환합니다.
  static AngelData? get currentAngel => _currentAngel;

  /// 현재 천사를 설정하고 저장소에 저장합니다.
  static Future<void> setCurrentAngel(AngelData angel) async {
    _currentAngel = angel;
    await _saveAngelToStorage(angel);
  }

  /// SharedPreferences에 천사 데이터 저장
  static Future<void> _saveAngelToStorage(AngelData angel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = jsonEncode(angel.toJson());
      await prefs.setString(_angelKey, angelJson);
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
  }

  /// SharedPreferences에서 천사 데이터 로드
  static Future<AngelData?> loadAngelFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = prefs.getString(_angelKey);

      if (angelJson != null) {
        final angelData = AngelData.fromJson(jsonDecode(angelJson));
        _currentAngel = angelData;
        return angelData;
      }
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
    return null;
  }

  /// 천사 데이터 삭제
  static Future<void> clearAngelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_angelKey);
      _currentAngel = null;
    } catch (e) {
      // 에러 처리 (로깅 등)
    }
  }
}
