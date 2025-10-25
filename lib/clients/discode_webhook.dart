import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum Priority { high, medium, low }

class DiscodeWebhookClient {
  // Discord 웹훅 URL (실제 사용 시 환경변수로 관리 권장)
  static String get _webhookUrl =>
      'https://discordapp.com/api/webhooks/1423903113735180430/S-5TiN9sO2fabbbBEPMnuYnPqZDoNiXfYyaAeaIXTWBebFlaH_8DKDxgb6WHG2g0tE7t';
  int _getColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 0xff0000;
      case Priority.medium:
        return 0x4ee037;
      case Priority.low:
        return 0x2cbfee;
    }
  }

  Future<void> sendMessage(
    String title,
    String message,
    Priority priority,
  ) async {
    final embeds = [
      {
        'title': title,
        'description': message,
        'color': _getColor(priority),
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    ];

    final response = await http.post(
      Uri.parse(_webhookUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      // Discord는 최상위에 객체를 요구하며, embeds는 배열로 'embeds' 키 아래에 전달해야 합니다.
      body: jsonEncode({'embeds': embeds}),
    );
    if (response.statusCode != 204) {
      debugPrint('Discord webhook 전송 실패: ${response.body}');
    }
  }
}
