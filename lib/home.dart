import 'package:flutter/material.dart';
import 'character_view.dart';
import 'main.dart' show bgColor, textColor;

// --- 천사 데이터 모델 ---
class AngelData {
  final String name;
  final String feature;
  final String animalType;
  final int faceType;
  final int faceColor;
  final int bodyIndex;
  final int emotionIndex;
  final int tailIndex;
  final DateTime createdAt;

  AngelData({
    required this.name,
    required this.feature,
    required this.animalType,
    required this.faceType,
    required this.faceColor,
    required this.bodyIndex,
    required this.emotionIndex,
    required this.tailIndex,
    required this.createdAt,
  });
}

// --- 전역 천사 데이터 관리자 ---
class AngelDataManager {
  static AngelData? _currentAngel;
  
  static AngelData? get currentAngel => _currentAngel;
  
  static void setCurrentAngel(AngelData angel) {
    _currentAngel = angel;
  }
}

// --- 홈 화면 ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사
  
  // 샘플 데이터 (실제로는 데이터베이스에서 가져올 예정)
  final List<String> _wishes = [
    '내 목표를 잊지 않고 나아가기',
    '긍정적인 생각하기',
    '하루에 3번 사랑하는 이에게 표현하기',
  ];
  
  final List<String> _goals = [
    '매일 30분 운동하기',
    '책 한 권 읽기',
    '새로운 기술 배우기',
  ];
  
  final List<String> _gratitudes = [
    '가족과 함께할 수 있어서',
    '맛있는 음식을 먹을 수 있어서',
    '건강한 몸을 가지고 있어서',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 상단 말풍선 영역
                _buildSpeechBubble(),
                const SizedBox(height: 20),
                
                // 천사 일러스트 영역
                _buildAngelIllustration(),
                const SizedBox(height: 20),
                
                // 탭과 목록 영역
                _buildTabSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    final angelData = AngelDataManager.currentAngel;
    final angelName = angelData?.name ?? '천사';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              angelData != null 
                ? '$angelName와 함께하는\n따뜻한 하루가 되길 바라요.'
                : '당신의 마음속 사랑은\n시간과 공간을 넘어 전해진다.',
              style: const TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('😊', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  Widget _buildAngelIllustration() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 일러스트 (하늘, 구름, 풀밭)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.green[100]!,
                  ],
                ),
              ),
            ),
          ),
          
          // 구름
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              width: 50,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // 태양
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌞', style: TextStyle(fontSize: 25)),
              ),
            ),
          ),
          
          // 풀밭과 꽃들
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // 꽃들
                  Positioned(
                    bottom: 10,
                    left: 30,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 40,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 천사 캐릭터 (완전 중앙에 배치)
          Center(
            child: Container(
              width: 200,
              height: 200,
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(0.8),
              //   shape: BoxShape.circle,
              //   border: Border.all(color: Colors.grey[300]!, width: 2),
              // ),
              child: _buildAngelCharacter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 제목과 달력
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getTitleText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'JUL 17',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 탭 버튼들
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildTabButton(0, '소망', Colors.blue[400]!),
                _buildTabButton(1, '목표', Colors.pink[400]!),
                _buildTabButton(2, '감사', Colors.yellow[600]!),
              ],
            ),
          ),
          
          // 내용 영역
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCurrentTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),
                ..._getCurrentList().asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getTabColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, Color color) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAngelCharacter() {
    final angelData = AngelDataManager.currentAngel;
    
    if (angelData == null) {
      // 천사가 없을 때 기본 이모지 표시
      return const Center(
        child: Text('🐱', style: TextStyle(fontSize: 60)),
      );
    }
    
    // 실제 생성된 천사 캐릭터 표시
    return Center(
      child: CharacterView(
        animalType: angelData.animalType,
        faceType: angelData.faceType,
        faceColor: angelData.faceColor,
        bodyIndex: angelData.bodyIndex,
        emotionIndex: angelData.emotionIndex,
        tailIndex: angelData.tailIndex,
      ),
    );
  }

  String _getTitleText() {
    final angelData = AngelDataManager.currentAngel;
    final angelName = angelData?.name ?? '천사';
    final today = DateTime.now();
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[today.weekday - 1];
    
    return '$angelName와 함께하는 $weekday 응원문구';
  }

  String _getCurrentTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return '오늘의 소망';
      case 1:
        return '오늘의 목표';
      case 2:
        return '오늘의 감사';
      default:
        return '오늘의 소망';
    }
  }

  List<String> _getCurrentList() {
    switch (_selectedTabIndex) {
      case 0:
        return _wishes;
      case 1:
        return _goals;
      case 2:
        return _gratitudes;
      default:
        return _wishes;
    }
  }

  Color _getTabColor() {
    switch (_selectedTabIndex) {
      case 0:
        return Colors.blue[400]!;
      case 1:
        return Colors.pink[400]!;
      case 2:
        return Colors.yellow[600]!;
      default:
        return Colors.blue[400]!;
    }
  }
}
