import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../managers/calendar_manager.dart';

class GoalTab extends StatefulWidget {
  const GoalTab({super.key});

  @override
  State<GoalTab> createState() => _GoalTabState();
}

class _GoalTabState extends State<GoalTab> {
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    final dateString = DateTime.now().toIso8601String().split('T')[0];
    final dayData = CalendarManager.getDayData(dateString);
    if (dayData != null && dayData.containsKey('goals')) {
      setState(() {
        _goals = List<Map<String, dynamic>>.from(dayData['goals']);
      });
    }
  }

  void _toggleGoal(int index) {
    setState(() {
      _goals[index]['completed'] = !_goals[index]['completed'];
    });
    // 변경사항 저장
    final dateString = DateTime.now().toIso8601String().split('T')[0];
    final dayData = CalendarManager.getDayData(dateString) ?? {};
    dayData['goals'] = _goals;
    CalendarManager.saveDayData(dateString, dayData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        return Card(
          child: ListTile(
            title: Text(
              goal['text'],
              style: TextStyle(
                decoration: goal['completed']
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            trailing: Checkbox(
              value: goal['completed'],
              onChanged: (_) => _toggleGoal(index),
              activeColor: primaryColor,
            ),
          ),
        );
      },
    );
  }
}
