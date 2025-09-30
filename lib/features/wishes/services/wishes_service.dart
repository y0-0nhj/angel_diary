import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wish_model.dart';

class WishesService {
  final String _storageKey = 'wishes_data';
  final int maxTotalWishes = 3;
  final Map<String, List<Wish>> _wishes = {};

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);

      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        _wishes.clear();
        decoded.forEach((key, value) {
          _wishes[key] = (value as List)
              .map((item) => Wish.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      throw Exception('Failed to load wishes: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _wishes.map(
        (key, value) => MapEntry(key, value.map((w) => w.toJson()).toList()),
      );
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to save wishes: $e');
    }
  }

  Future<void> addWish(String date, Wish wish) async {
    await _loadFromStorage();

    int totalWishes = 0;
    _wishes.values.forEach((wishList) => totalWishes += wishList.length);

    if (totalWishes >= maxTotalWishes) {
      throw Exception(
        'Maximum number of total wishes ($maxTotalWishes) has been reached. You can only modify existing wishes.',
      );
    }

    if (!_wishes.containsKey(date)) {
      _wishes[date] = [];
    }

    _wishes[date]!.add(wish);
    await _saveToStorage();
  }

  Future<List<Wish>> getWishes(String date) async {
    await _loadFromStorage();
    return _wishes[date] ?? [];
  }

  Future<void> updateWish(String date, Wish updatedWish) async {
    if (!_wishes.containsKey(date)) return;

    final index = _wishes[date]!.indexWhere((w) => w.id == updatedWish.id);
    if (index != -1) {
      _wishes[date]![index] = updatedWish;
      await _saveToStorage();
    }
  }

  Future<void> deleteWish(String date, String wishId) async {
    if (!_wishes.containsKey(date)) return;

    _wishes[date]!.removeWhere((w) => w.id == wishId);
    await _saveToStorage();
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _wishes.clear();
    } catch (e) {
      throw Exception('Failed to clear wishes: $e');
    }
  }

  Future<List<Wish>> getTodayWishes() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getWishes(dateStr);
  }
}
