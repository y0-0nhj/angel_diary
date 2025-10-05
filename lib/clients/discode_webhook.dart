import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiscodeWebhook {
  Future<void> sendMessage() async {
    final response = await http.post(
      Uri.parse(dotenv.env['DISCORD_WEBHOOK_URL']!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': '테스트'}),
    );
  }
}
