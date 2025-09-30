import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_entry_model.dart';

class CalendarService {
  static const String _storageKey = 'calendar_data';
  static final Map<String, CalendarEntry> _entries = {};

  static Future<void> saveEntry(CalendarEntry entry) async {
    try {
      _entries[entry.date] = entry;
      await _saveToStorage();
    } catch (e) {
      throw Exception('Failed to save calendar entry: $e');
    }
  }

  static Future<CalendarEntry?> getEntry(String date) async {
    await _loadFromStorage();
    return _entries[date];
  }

  static Future<Map<String, CalendarEntry>> getAllEntries() async {
    await _loadFromStorage();
    return Map.from(_entries);
  }

  static Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _entries.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to save calendar data: $e');
    }
  }

  static Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);

      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        _entries.clear();
        decoded.forEach((key, value) {
          _entries[key] = CalendarEntry.fromJson(value);
        });
      }
    } catch (e) {
      throw Exception('Failed to load calendar data: $e');
    }
  }

  static Future<void> deleteEntry(String date) async {
    _entries.remove(date);
    await _saveToStorage();
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _entries.clear();
    } catch (e) {
      throw Exception('Failed to clear calendar data: $e');
    }
  }
}
