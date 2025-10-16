// 천사(캐릭터) 데이터의 인메모리 상태와 로컬 영속화를 관리합니다.
// - 저장 위치: SharedPreferences (키: 'angel_data')
// - 책임: 현재 천사 설정/로드/삭제, JSON 직렬화/역직렬화
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/angel_data.dart';

/// 천사 데이터에 대한 간단한 저장 관리자.
///
/// 앱 전역에서 최근 사용한 천사 설정을 인메모리에 보관하고,
/// SharedPreferences에 JSON 형태로 저장/로드합니다.
class AngelManager {
  static AngelData? _currentAngel;
  static const String _angelKey = 'angel_data';

  static AngelData? get currentAngel => _currentAngel;

  /// 현재 천사 데이터를 설정하고 영속 저장합니다.
  static Future<void> setCurrentAngel(AngelData angel) async {
    _currentAngel = angel;
    await _saveAngelToStorage(angel);
  }

  /// 내부: SharedPreferences에 천사 데이터를 JSON으로 저장합니다.
  static Future<void> _saveAngelToStorage(AngelData angel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = jsonEncode(angel.toJson());
      await prefs.setString(_angelKey, angelJson);
    } catch (e) {
      // 저장 실패 시 조용히 무시합니다. (향후 로깅/리포팅 연동 지점)
    }
  }

  /// SharedPreferences에서 천사 데이터를 읽어 인메모리에 로드합니다.
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
      // 로드 실패 시 null 반환.
    }
    return null;
  }

  /// 저장된 천사 데이터를 삭제하고 인메모리 상태를 초기화합니다.
  static Future<void> clearAngelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_angelKey);
      _currentAngel = null;
    } catch (e) {
      // 삭제 실패 시 조용히 무시합니다.
    }
  }
}
