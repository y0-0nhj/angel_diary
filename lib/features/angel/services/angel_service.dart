import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/angel_model.dart';

class AngelService {
  static const String _storageKey = 'angel_data';
  static Angel? _currentAngel;

  static Angel? get currentAngel => _currentAngel;

  static Future<void> saveAngel(Angel angel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = jsonEncode(angel.toJson());
      await prefs.setString(_storageKey, angelJson);
      _currentAngel = angel;
    } catch (e) {
      throw Exception('Failed to save angel data: $e');
    }
  }

  static Future<Angel?> loadAngel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = prefs.getString(_storageKey);

      if (angelJson != null) {
        final angel = Angel.fromJson(jsonDecode(angelJson));
        _currentAngel = angel;
        return angel;
      }
    } catch (e) {
      throw Exception('Failed to load angel data: $e');
    }
    return null;
  }

  static Future<void> deleteAngel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _currentAngel = null;
    } catch (e) {
      throw Exception('Failed to delete angel data: $e');
    }
  }

  static Future<void> updateAngelEmotion(int emotionIndex) async {
    if (_currentAngel == null) return;

    final updatedAngel = Angel(
      name: _currentAngel!.name,
      feature: _currentAngel!.feature,
      animalType: _currentAngel!.animalType,
      faceType: _currentAngel!.faceType,
      faceColor: _currentAngel!.faceColor,
      bodyIndex: _currentAngel!.bodyIndex,
      emotionIndex: emotionIndex,
      tailIndex: _currentAngel!.tailIndex,
      createdAt: _currentAngel!.createdAt,
    );

    await saveAngel(updatedAngel);
  }
}
