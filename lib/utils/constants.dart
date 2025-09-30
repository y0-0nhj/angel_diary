import 'package:flutter/material.dart';

// 색상 정의
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;

// 메시지 데이터
final List<Map<String, String>> messages = [
  {'text': '하나님이 너와 함께 하시니라', 'source': '창세기 28:15'},
  {'text': '내가 너를 위하여 정한 계획은 평안이요 재앙이 아니니라', 'source': '예레미야 29:11'},
  {'text': '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'source': '시편 23:1'},
  {'text': '모든 일이 합력하여 선을 이룬다', 'source': '로마서 8:28'},
  {'text': '오늘 하루를 감사하며 시작하세요', 'source': '일상의 지혜'},
  {'text': '작은 기쁨도 소중히 여기세요', 'source': '일상의 지혜'},
];

// 응원 메시지
final List<String> encouragementMessages = [
  '정말 잘하고 있어요! 💪',
  '훌륭해요! 계속 이렇게 해요! ✨',
  '오늘도 멋진 하루를 보내고 있네요! 🌟',
  '정말 대단해요! 자랑스러워요! 👏',
  '완벽해요! 정말 잘했어요! 🎉',
];

// 애니메이션 지속 시간
const Duration animationDuration = Duration(milliseconds: 500);
