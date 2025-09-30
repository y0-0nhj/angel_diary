import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../managers/calendar_manager.dart';

class GratitudeTab extends StatefulWidget {
  const GratitudeTab({super.key});

  @override
  State<GratitudeTab> createState() => _GratitudeTabState();
}

class _GratitudeTabState extends State<GratitudeTab> {
  List<Map<String, dynamic>> _gratitudes = [];

  @override
  void initState() {
    super.initState();
    _loadGratitudes();
  }

  void _loadGratitudes() {
    final dateString = DateTime.now().toIso8601String().split('T')[0];
    final dayData = CalendarManager.getDayData(dateString);
    if (dayData != null && dayData.containsKey('gratitudes')) {
      setState(() {
        _gratitudes = List<Map<String, dynamic>>.from(dayData['gratitudes']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _gratitudes.length,
      itemBuilder: (context, index) {
        final gratitude = _gratitudes[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: primaryColor),
            title: Text(gratitude['text']),
            subtitle: Text(gratitude['category'] ?? ''),
          ),
        );
      },
    );
  }
}
