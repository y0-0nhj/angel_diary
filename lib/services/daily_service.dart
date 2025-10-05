import 'package:shared_preferences/shared_preferences.dart';
import '../managers/calendar_manager.dart';

class DailyService {
  static const String _lastDateKey = 'last_data_date';

  static Future<bool> shouldGenerateNewData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_lastDateKey);

    return lastDate != today;
  }

  static Future<void> generateDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 오늘의 데이터 생성
    final dayData = {
      'goals': _generateRandomGoals(),
      'gratitudes': _generateRandomGratitudes(),
      'diary': '',
    };

    // 데이터 저장
    await CalendarManager.saveDayData(today, dayData);
    await prefs.setString(_lastDateKey, today);
  }

  static List<Map<String, dynamic>> _generateRandomGoals() {
    // 예시 목표들 (실제로는 더 많은 목표들이 있을 수 있음)
    final goals = [
      {'text': '운동하기', 'category': '건강'},
      {'text': '독서하기', 'category': '자기계발'},
      {'text': '일기쓰기', 'category': '습관'},
    ];

    return goals.map((goal) => {...goal, 'completed': false}).toList();
  }

  static List<Map<String, dynamic>> _generateRandomGratitudes() {
    // 예시 감사 항목들
    return [
      {'text': '오늘 하루도 건강하게 시작할 수 있어서 감사합니다', 'category': '건강'},
      {'text': '가족과 함께할 수 있어서 감사합니다', 'category': '가족'},
      {'text': '새로운 하루를 맞이할 수 있어서 감사합니다', 'category': '일상'},
    ];
  }
}
