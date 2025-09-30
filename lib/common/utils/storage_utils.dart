import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static Future<void> saveData<T>(String key, T data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (data is String) {
        await prefs.setString(key, data);
      } else if (data is bool) {
        await prefs.setBool(key, data);
      } else if (data is int) {
        await prefs.setInt(key, data);
      } else if (data is double) {
        await prefs.setDouble(key, data);
      } else if (data is List<String>) {
        await prefs.setStringList(key, data);
      } else {
        await prefs.setString(key, jsonEncode(data));
      }
    } catch (e) {
      throw Exception('Failed to save data: $e');
    }
  }

  static Future<T?> loadData<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(key)) return null;

      if (T == String) {
        return prefs.getString(key) as T?;
      } else if (T == bool) {
        return prefs.getBool(key) as T?;
      } else if (T == int) {
        return prefs.getInt(key) as T?;
      } else if (T == double) {
        return prefs.getDouble(key) as T?;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T?;
      } else {
        final jsonString = prefs.getString(key);
        if (jsonString == null) return null;
        return jsonDecode(jsonString) as T?;
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<void> removeData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to remove data: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
