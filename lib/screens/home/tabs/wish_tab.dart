import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../managers/calendar_manager.dart';

class WishTab extends StatefulWidget {
  const WishTab({super.key});

  @override
  State<WishTab> createState() => _WishTabState();
}

class _WishTabState extends State<WishTab> {
  List<Map<String, dynamic>> _wishes = [];

  @override
  void initState() {
    super.initState();
    _loadWishes();
  }

  void _loadWishes() {
    final dateString = DateTime.now().toIso8601String().split('T')[0];
    setState(() {
      _wishes = CalendarManager.getWishes(dateString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _wishes.length,
      itemBuilder: (context, index) {
        final wish = _wishes[index];
        return Card(
          child: ListTile(
            title: Text(wish['text']),
            trailing: Icon(Icons.favorite, color: primaryColor),
          ),
        );
      },
    );
  }
}
