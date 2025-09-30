import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/angel_data.dart';

class AngelManager {
  static AngelData? _currentAngel;
  static const String _angelKey = 'angel_data';

  static AngelData? get currentAngel => _currentAngel;

  static Future<void> setCurrentAngel(AngelData angel) async {
    _currentAngel = angel;
    await _saveAngelToStorage(angel);
  }

  static Future<void> _saveAngelToStorage(AngelData angel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = jsonEncode(angel.toJson());
      await prefs.setString(_angelKey, angelJson);
    } catch (e) {
      // Handle error
    }
  }

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
      // Handle error
    }
    return null;
  }

  static Future<void> clearAngelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_angelKey);
      _currentAngel = null;
    } catch (e) {
      // Handle error
    }
  }
}
