import 'package:flutter/material.dart';
import 'dart:math';
import 'character_view.dart';
import 'main.dart' show bgColor, textColor;
import 'package:table_calendar/table_calendar.dart';

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

// --- 전역 캘린더 데이터 관리자 ---
class CalendarDataManager {
  static final Map<String, Map<String, List<Map<String, dynamic>>>> _calendarData = {};
  
  static Map<String, List<Map<String, dynamic>>>? getDayData(String dateString) {
    return _calendarData[dateString];
  }
  
  static void saveDayData(String dateString, Map<String, List<Map<String, dynamic>>> dayData) {
    _calendarData[dateString] = dayData;
  }
  
  static Map<String, Map<String, List<Map<String, dynamic>>>> get allData => _calendarData;
}

// --- 홈 화면 ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사
  int _currentEmotionIndex = 1; // 현재 표정 인덱스
  String _currentMessage = ''; // 현재 표시되는 메시지
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  
  // 성경구절 및 조언 메시지 데이터
  final List<Map<String, String>> _messages = [
    {'text': '하나님이 너와 함께 하시니라', 'source': '창세기 28:15'},
    {'text': '내가 너를 위하여 정한 계획은 평안이요 재앙이 아니니라', 'source': '예레미야 29:11'},
    {'text': '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'source': '시편 23:1'},
    {'text': '모든 일이 합력하여 선을 이룬다', 'source': '로마서 8:28'},
    {'text': '오늘 하루를 감사하며 시작하세요', 'source': '일상의 지혜'},
    {'text': '작은 기쁨도 소중히 여기세요', 'source': '일상의 지혜'},
    {'text': '사랑은 모든 것을 이깁니다', 'source': '일상의 지혜'},
    {'text': '희망을 잃지 마세요', 'source': '일상의 지혜'},
    {'text': '오늘도 최선을 다하세요', 'source': '일상의 지혜'},
    {'text': '하나님의 사랑이 당신을 감싸고 있습니다', 'source': '일상의 지혜'},
  ];
  
  @override
  void initState() {
    super.initState();
    _selectRandomMessage();
    _generateRandomWishes();
  }

  // 랜덤 소망 생성
  void _generateRandomWishes() {
    final random = Random();
    List<Map<String, dynamic>> newWishes = [];
    
    // 각 카테고리에서 1개씩 랜덤 선택
    _wishCategories.forEach((category, items) {
      final selectedItem = items[random.nextInt(items.length)];
      newWishes.add({
        'text': selectedItem,
        'completed': false,
        'category': category,
      });
    });
    
    setState(() {
      _wishes = newWishes;
    });
  }
  
  // 랜덤 메시지 선택
  void _selectRandomMessage() {
    if (_messages.isNotEmpty) {
      final random = Random();
      final selectedMessage = _messages[random.nextInt(_messages.length)];
      setState(() {
        _currentMessage = selectedMessage['text'] ?? '오늘도 좋은 하루 되세요';
      });
    }
  }
  
  // 소망 카테고리별 데이터
  final Map<String, List<String>> _wishCategories = {
    'kindness': [
      '가족이나 친구에게 칭찬 한마디 하기',
      '가장 가까운 사람에게 "고맙다"고 표현하기',
      '카페나 편의점 직원분께 웃으며 인사하기',
      '길에 떨어진 쓰레기 하나 줍기',
      '동네 길고양이를 위해 물그릇 채워주기',
    ],
    'growth': [
      '관심 분야 책 10페이지 읽기',
      '아침에 일어나 이불 정리하기',
      '미뤄뒀던 작은 일 한 가지 끝내기',
      '새로운 단어 하나 배우고 하루 동안 세 번 써먹기',
      '유튜브로 5분짜리 새로운 지식 영상 보기',
    ],
    'gratitude': [
      '오늘 감사했던 일 3가지 자기 전에 적어보기',
      '하늘 한번 올려다보고 깊게 숨 쉬기',
      '내가 가진 것 중, 당연하지 않은 것 하나 떠올리기',
      '하루를 마무리하며 5분 동안 짧은 일기 쓰기',
      '가장 좋아하는 성경 구절이나 명언 한 줄 필사하기',
    ],
  };

  // 체크박스 상태를 포함한 데이터 구조
  List<Map<String, dynamic>> _wishes = [];
  
  List<Map<String, dynamic>> _goals = [
    {'text': '매일 30분 운동하기', 'completed': false},
    {'text': '책 한 권 읽기', 'completed': false},
    {'text': '새로운 기술 배우기', 'completed': false},
  ];
  
  List<Map<String, dynamic>> _gratitudes = [
    {'text': '가족과 함께할 수 있어서', 'completed': false},
    {'text': '맛있는 음식을 먹을 수 있어서', 'completed': false},
    {'text': '건강한 몸을 가지고 있어서', 'completed': false},
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
            color: Colors.black.withValues(alpha: 0.1),
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
                ? () {
                    final randomMessage = _messages[Random().nextInt(_messages.length)];
                    return '$angelName와(과) 함께하는 따뜻한 하루가 되길 바라요.\n${randomMessage['text']}\n- ${randomMessage['source']}';
                  }()
                : () {
                    final randomMessage = _messages[Random().nextInt(_messages.length)];
                    return '당신의 마음속 사랑은\n시간과 공간을 넘어 전해진다.\n${randomMessage['text']}\n- ${randomMessage['source']}';
                  }()
              ,
              style: const TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.4,
              ),
            )
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
            color: Colors.black.withValues(alpha: 0.1),
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
          
          // 천사 캐릭터 (중앙에서 살짝 아래로 배치)
          Positioned(
            left: 0,
            right: 0,
            top: 120, // 천사를 아래로 이동 (기존 중앙에서 20px 아래)
            child: Center(
              child: SizedBox(
                width: 100, // 200 * 0.5 = 100
                height: 100, // 200 * 0.5 = 100
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.8),
                //   shape: BoxShape.circle,
                //   border: Border.all(color: Colors.grey[300]!, width: 2),
                // ),
                child: _buildAngelCharacter(),
              ),
            ),
          ),
          
          // 우체통 (천사 오른쪽에 배치)
          Positioned(
            right: 30,
            bottom: 60,
            child: GestureDetector(
              onTap: () => _showLetterWritingPopup(),
              child: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 우체통 상단
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'POST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // 우체통 몸체
                    Expanded(
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mail,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 제목과 달력
           Padding(
             padding: const EdgeInsets.all(5),
             child: Row(
          //     children: [
          //         Expanded(
          //           child: Text(
          //             _getTitleText(),
          //             style: const TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: textColor,
          //             ),
          //           ),
          //         ),
          //       Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //         decoration: BoxDecoration(
          //           color: Colors.red[100],
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //         child: const Text(
          //           'JUL 17',
          //           style: TextStyle(
          //             fontSize: 12,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.red,
          //           ),
          //         ),
          //       ),
          //     ],
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
                _buildTabButton(0, '소망', Colors.blue[200]!),
                _buildTabButton(1, '목표', Colors.pink[200]!),
                _buildTabButton(2, '감사', Colors.yellow[400]!),
                _buildCalendarTab(),
              ],
            ),
          ),
          
          // 내용 영역
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getCurrentTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedTabIndex == 0) // 소망 탭일 때만 새로고침 버튼 표시
                      GestureDetector(
                        onTap: _generateRandomWishes,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${_selectedDate.month}/${_selectedDate.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ..._getCurrentList().asMap().entries.map((entry) {
                  final item = entry.value;
                  final isCompleted = item['completed'] as bool;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // 번호 (앞에 유지)
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
                        // 텍스트 (가운데)
                        Expanded(
                          child: Text(
                            item['text'],
                            style: TextStyle(
                              fontSize: 17,
                              color: isCompleted ? Colors.lightGreen : textColor,
                              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 체크박스 (맨 뒤로 이동)
                        GestureDetector(
                          onTap: () => _toggleItem(entry.key),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.lightGreen : Colors.transparent,
                              border: Border.all(
                                color: isCompleted ? Colors.lightGreen : Colors.grey[400]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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

  Widget _buildCalendarTab() {
    return GestureDetector(
      onTap: () => _showCalendarPopup(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 20,
          color: textColor,
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
        emotionIndex: _currentEmotionIndex, // 현재 표정 사용
        tailIndex: angelData.tailIndex,
        enableTailAnimation: true, // 홈화면에서 꼬리 애니메이션 활성화
        scaleFactor: 0.61, // 홈화면에서는 0.61배 크기
        onEmotionChanged: (newEmotionIndex) {
          // 표정 변경 콜백
          setState(() {
            _currentEmotionIndex = newEmotionIndex;
          });
        },
      ),
    );
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

  List<Map<String, dynamic>> _getCurrentList() {
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

  // 체크박스 상태 변경 함수
  void _toggleItem(int index) {
    setState(() {
      final currentList = _getCurrentList();
      currentList[index]['completed'] = !currentList[index]['completed'];
      
      // 선택된 날짜의 데이터를 캘린더에 저장
      _saveToCalendar();
    });
  }

  // 선택된 날짜의 데이터를 캘린더에 저장
  void _saveToCalendar() {
    final dateString = _getDateString(_selectedDate);
    
    // 전역 캘린더 데이터에 저장 (실제로는 데이터베이스에 저장)
    CalendarDataManager.saveDayData(dateString, {
      'wishes': List<Map<String, dynamic>>.from(_wishes),
      'goals': List<Map<String, dynamic>>.from(_goals),
      'gratitudes': List<Map<String, dynamic>>.from(_gratitudes),
    });
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  // 편지 쓰기 팝업 표시
  void _showLetterWritingPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LetterWritingDialog();
      },
    );
  }

  // 캘린더 팝업 표시
  void _showCalendarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarDialog(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _loadDataForDate(date);
            });
          },
        );
      },
    );
  }

  // 특정 날짜의 데이터 로드
  void _loadDataForDate(DateTime date) {
    final dateString = _getDateString(date);
    final dayData = CalendarDataManager.getDayData(dateString);
    
    if (dayData != null) {
      setState(() {
        _wishes = List<Map<String, dynamic>>.from(dayData['wishes'] ?? []);
        _goals = List<Map<String, dynamic>>.from(dayData['goals'] ?? []);
        _gratitudes = List<Map<String, dynamic>>.from(dayData['gratitudes'] ?? []);
      });
    } else {
      // 해당 날짜에 데이터가 없으면 랜덤 소망 생성 및 기본값으로 초기화
      _generateRandomWishes();
      setState(() {
        _goals = [
          {'text': '매일 30분 운동하기', 'completed': false},
          {'text': '책 한 권 읽기', 'completed': false},
          {'text': '새로운 기술 배우기', 'completed': false},
        ];
        _gratitudes = [
          {'text': '가족과 함께할 수 있어서', 'completed': false},
          {'text': '맛있는 음식을 먹을 수 있어서', 'completed': false},
          {'text': '건강한 몸을 가지고 있어서', 'completed': false},
        ];
      });
    }
  }
}

// 편지 쓰기 다이얼로그
class LetterWritingDialog extends StatefulWidget {
  @override
  _LetterWritingDialogState createState() => _LetterWritingDialogState();
}

class _LetterWritingDialogState extends State<LetterWritingDialog> {
  final TextEditingController _letterController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String _selectedEmotion = '😊'; // 기본 표정

  final List<String> _emotions = ['😊', '😢', '😍', '🤔', '😴', '😤', '🥰', '😭'];

  @override
  void dispose() {
    _letterController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                const Icon(Icons.mail, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                const Text(
                  '편지 쓰기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 받는 사람
            const Text(
              '받는 사람',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                hintText: '누구에게 편지를 보낼까요?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 표정 선택
            const Text(
              '오늘의 기분',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emotions.length,
                itemBuilder: (context, index) {
                  final emotion = _emotions[index];
                  final isSelected = _selectedEmotion == emotion;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmotion = emotion;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emotion,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 편지 내용
            const Text(
              '편지 내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _letterController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '마음을 담아 편지를 써보세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '편지 보내기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendLetter() {
    if (_recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('받는 이를 입력해주세요.')),
      );
      return;
    }

    if (_letterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('편지 내용을 입력해주세요.')),
      );
      return;
    }

    // 편지 저장 로직 (여기서는 간단히 스낵바로 표시)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_recipientController.text}님에게 편지를 보냈습니다! 💌'),
        backgroundColor: Colors.lightGreen,
      ),
    );

    Navigator.of(context).pop();
  }
}

// 캘린더 다이얼로그
class CalendarDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  
  const CalendarDialog({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _CalendarDialogState createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedCategory = 0; // 0: 소망, 1: 목표, 2: 감사
  bool _isWeekView = true; // true: 이번주만 보기, false: 이번달 펼쳐보기

  // 샘플 데이터 (실제로는 데이터베이스에서 가져올 예정)
  final Map<String, Map<String, List<Map<String, dynamic>>>> _sampleData = {
    '2024-07-17': {
      'wishes': [
        {'text': '내 목표를 잊지 않고 나아가기', 'completed': true},
        {'text': '긍정적인 생각하기', 'completed': false},
        {'text': '하루에 3번 사랑하는 이에게 표현하기', 'completed': true},
      ],
      'goals': [
        {'text': '매일 30분 운동하기', 'completed': true},
        {'text': '책 한 권 읽기', 'completed': false},
        {'text': '새로운 기술 배우기', 'completed': true},
      ],
      'gratitudes': [
        {'text': '가족과 함께할 수 있어서', 'completed': true},
        {'text': '맛있는 음식을 먹을 수 있어서', 'completed': true},
        {'text': '건강한 몸을 가지고 있어서', 'completed': false},
      ],
    },
    '2024-07-16': {
      'wishes': [
        {'text': '오늘도 긍정적으로 시작하기', 'completed': true},
        {'text': '작은 기쁨 찾기', 'completed': true},
      ],
      'goals': [
        {'text': '아침 운동하기', 'completed': false},
        {'text': '독서 1시간', 'completed': true},
      ],
      'gratitudes': [
        {'text': '좋은 날씨에 감사', 'completed': true},
        {'text': '친구들과의 만남', 'completed': true},
      ],
    },
    '2024-07-15': {
      'wishes': [
        {'text': '새로운 도전에 도전하기', 'completed': false},
      ],
      'goals': [
        {'text': '프로젝트 완료하기', 'completed': true},
      ],
      'gratitudes': [
        {'text': '팀원들의 도움', 'completed': true},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    _focusedDay = widget.selectedDate;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateString = _getDateString(day);
    
    // 전역 데이터에서 먼저 확인, 없으면 샘플 데이터에서 확인
    final dayData = CalendarDataManager.getDayData(dateString) ?? 
                   _sampleData[dateString] ?? {
      'wishes': <Map<String, dynamic>>[],
      'goals': <Map<String, dynamic>>[],
      'gratitudes': <Map<String, dynamic>>[],
    };

    String categoryKey = '';
    switch (_selectedCategory) {
      case 0:
        categoryKey = 'wishes';
        break;
      case 1:
        categoryKey = 'goals';
        break;
      case 2:
        categoryKey = 'gratitudes';
        break;
    }

    return dayData[categoryKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
      
      // 홈 화면에 선택된 날짜 전달
      widget.onDateSelected(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                const Text(
                  '날짜별 체크리스트',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                // 뷰 전환 버튼
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isWeekView = !_isWeekView;
                    });
                  },
                  icon: Icon(
                    _isWeekView ? Icons.calendar_view_month : Icons.view_week,
                    color: Colors.blue,
                  ),
                  tooltip: _isWeekView ? '이번달 펼쳐보기' : '이번주만 보기',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 캘린더 영역
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _isWeekView ? _buildWeekView() : _buildMonthView(),
            ),
            const SizedBox(height: 20),

            // 카테고리 탭
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildCategoryTab(0, '소망', Colors.blue[400]!),
                  _buildCategoryTab(1, '목표', Colors.pink[400]!),
                  _buildCategoryTab(2, '감사', Colors.yellow[600]!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 선택된 날짜와 작업 목록
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택된 날짜 표시 (왼쪽)
                  Container(
                    width: 80,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${_selectedDay?.day ?? DateTime.now().day}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _getWeekdayShort(_selectedDay ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 작업 목록 (오른쪽)
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return _buildChecklistContent(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(int index, String title, Color color) {
    final isSelected = _selectedCategory == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = index;
          });
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        },
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

  Widget _buildChecklistContent(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '이 날의 ${_getCategoryName(_selectedCategory)}이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item['completed'] ? Colors.lightGreen : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                color: item['completed'] ? Colors.lightGreen : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['text'],
                  style: TextStyle(
                    fontSize: 14,
                    color: item['completed'] ? Colors.grey[600] : textColor,
                    decoration: item['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getCategoryName(int category) {
    switch (category) {
      case 0:
        return '소망';
      case 1:
        return '목표';
      case 2:
        return '감사';
      default:
        return '';
    }
  }

  // 주간 날짜 목록 가져오기
  List<DateTime> _getWeekDays(DateTime focusedDay) {
    final startOfWeek = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // 월/년도 문자열 가져오기
  String _getMonthYearString(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // 해당 날짜에 이벤트가 있는지 확인
  bool _hasEventsForDay(DateTime day) {
    final dateString = _getDateString(day);
    final dayData = CalendarDataManager.getDayData(dateString) ?? _sampleData[dateString];
    if (dayData == null) return false;
    
    for (String category in ['wishes', 'goals', 'gratitudes']) {
      final items = dayData[category] ?? [];
      if (items.isNotEmpty) return true;
    }
    return false;
  }

  // 요일 축약형 가져오기
  String _getWeekdayShort(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[date.weekday % 7];
  }

  // 이번주만 보기 뷰 빌드
  Widget _buildWeekView() {
    return Column(
      children: [
        // 주간 헤더
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            '이번주 (${_getWeekRangeString(_focusedDay)})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        // 요일 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: day == '일' || day == '토' 
                              ? Colors.red[400] 
                              : Colors.grey[600],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        // 주간 날짜 행
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _getWeekDays(_focusedDay).map((day) {
              final isSelected = isSameDay(_selectedDay, day);
              final isToday = isSameDay(DateTime.now(), day);
              final hasEvents = _hasEventsForDay(day);
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onDaySelected(day, day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[400] : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.white 
                                    : isToday 
                                        ? Colors.red[700]
                                        : day.weekday == DateTime.sunday || day.weekday == DateTime.saturday
                                            ? Colors.red[400]
                                            : textColor,
                              ),
                            ),
                          ),
                        ),
                        if (hasEvents)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 월별 뷰 빌드
  Widget _buildMonthView() {
    return Column(
      children: [
        // 월/년도 헤더
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _getMonthYearString(_focusedDay),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // 요일 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: day == 'Sun' || day == 'Sat' 
                              ? Colors.red[400] 
                              : Colors.grey[600],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        // 날짜 행
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _getWeekDays(_focusedDay).map((day) {
              final isSelected = isSameDay(_selectedDay, day);
              final isToday = isSameDay(DateTime.now(), day);
              final hasEvents = _hasEventsForDay(day);
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onDaySelected(day, day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[400] : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.white 
                                    : isToday 
                                        ? Colors.red[700]
                                        : day.weekday == DateTime.sunday || day.weekday == DateTime.saturday
                                            ? Colors.red[400]
                                            : textColor,
                              ),
                            ),
                          ),
                        ),
                        if (hasEvents)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 주간 범위 문자열 가져오기
  String _getWeekRangeString(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.month}/${startOfWeek.day} - ${endOfWeek.month}/${endOfWeek.day}';
  }
}
