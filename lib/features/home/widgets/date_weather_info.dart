import 'package:flutter/material.dart';
import 'dart:math';
import '../../../generated/l10n/app_localizations.dart';

class DateWeatherInfo extends StatelessWidget {
  const DateWeatherInfo({super.key});

  // 랜덤 기온 생성 (25~29도)
  int _getRandomTemperature() {
    final now = DateTime.now();
    // 날짜를 기반으로 시드값 생성 (같은 날에는 같은 기온)
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    return 25 + random.nextInt(5); // 25, 26, 27, 28, 29 중 랜덤
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final temperature = _getRandomTemperature();

    // 요일 배열을 다국어로 변경
    final weekdays = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];
    final weekday = weekdays[now.weekday % 7];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${now.year}년 ${now.month.toString().padLeft(2, '0')}월 ${now.day.toString().padLeft(2, '0')}일 $weekday',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // 기온 정보
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange[400], size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기온: $temperature°C',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '날씨: 맑음',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
