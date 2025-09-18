import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'character_view.dart';
import 'main.dart' show bgColor, textColor, primaryColor, AngelDiaryApp;
import 'package:table_calendar/table_calendar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'diary_dialog.dart';
import 'simple_calendar_dialog.dart';
import 'generated/l10n/app_localizations.dart';
import 'language_manager.dart';

// 말풍선 꼬리를 그리는 CustomPainter
class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



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

  // JSON 변환을 위한 메서드들
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'feature': feature,
      'animalType': animalType,
      'faceType': faceType,
      'faceColor': faceColor,
      'bodyIndex': bodyIndex,
      'emotionIndex': emotionIndex,
      'tailIndex': tailIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AngelData.fromJson(Map<String, dynamic> json) {
    return AngelData(
      name: json['name'],
      feature: json['feature'],
      animalType: json['animalType'],
      faceType: json['faceType'],
      faceColor: json['faceColor'],
      bodyIndex: json['bodyIndex'],
      emotionIndex: json['emotionIndex'],
      tailIndex: json['tailIndex'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// --- 전역 천사 데이터 관리자 ---
class AngelDataManager {
  static AngelData? _currentAngel;
  static const String _angelKey = 'angel_data';
  
  static AngelData? get currentAngel => _currentAngel;
  
  static Future<void> setCurrentAngel(AngelData angel) async {
    _currentAngel = angel;
    await _saveAngelToStorage(angel);
  }
  
  // SharedPreferences에 천사 데이터 저장
  static Future<void> _saveAngelToStorage(AngelData angel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = jsonEncode(angel.toJson());
      await prefs.setString(_angelKey, angelJson);
    } catch (e) {
    }
  }
  
  // SharedPreferences에서 천사 데이터 로드
  static Future<AngelData?> loadAngelFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angelJson = prefs.getString(_angelKey);
      
      if (angelJson != null) {
        final angelData = AngelData.fromJson(jsonDecode(angelJson));
        _currentAngel = angelData;
        return angelData;
      }
    } catch (e) {
    }
    return null;
  }
  
  // 천사 데이터 삭제
  static Future<void> clearAngelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_angelKey);
      _currentAngel = null;
    } catch (e) {
    }
  }
}

// --- 전역 캘린더 데이터 관리자 ---
class CalendarDataManager {
  static final Map<String, Map<String, dynamic>> _calendarData = {};
  static final Map<String, List<Map<String, dynamic>>> _persistentWishes = {}; // 소망은 지속적으로 유지
  static const String _calendarKey = 'calendar_data';
  static const String _wishesKey = 'wishes_data';
  
  static Map<String, dynamic>? getDayData(String dateString) {
    return _calendarData[dateString];
  }
  
  static Future<void> saveDayData(String dateString, Map<String, dynamic> dayData) async {
    _calendarData[dateString] = dayData;
    await _saveCalendarToStorage();
  }
  
  static Future<void> saveDiary(String dateString, String diaryContent) async {
    if (_calendarData[dateString] == null) {
      _calendarData[dateString] = {
        'wishes': <Map<String, dynamic>>[],
        'goals': <Map<String, dynamic>>[],
        'gratitudes': <Map<String, dynamic>>[],
        'diary': '',
      };
    }
    _calendarData[dateString]!['diary'] = diaryContent;
    await _saveCalendarToStorage();
  }
  
  static String? getDiary(String dateString) {
    return _calendarData[dateString]?['diary'] as String?;
  }
  
  // 소망 전용 저장/조회 메서드
  static Future<void> saveWishes(String dateString, List<Map<String, dynamic>> wishes) async {
    _persistentWishes[dateString] = List<Map<String, dynamic>>.from(wishes);
    await _saveWishesToStorage();
  }
  
  static List<Map<String, dynamic>> getWishes(String dateString) {
    return _persistentWishes[dateString] ?? [];
  }
  
  // 소망이 설정되어 있는지 확인
  static bool hasWishes(String dateString) {
    return _persistentWishes.containsKey(dateString) && _persistentWishes[dateString]!.isNotEmpty;
  }
  
  static Map<String, Map<String, dynamic>> get allData => _calendarData;
  
  // SharedPreferences에 캘린더 데이터 저장
  static Future<void> _saveCalendarToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calendarJson = jsonEncode(_calendarData);
      await prefs.setString(_calendarKey, calendarJson);
    } catch (e) {
    }
  }
  
  // SharedPreferences에 소망 데이터 저장
  static Future<void> _saveWishesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishesJson = jsonEncode(_persistentWishes);
      await prefs.setString(_wishesKey, wishesJson);
    } catch (e) {
    }
  }
  
  // SharedPreferences에서 캘린더 데이터 로드
  static Future<void> loadCalendarFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 캘린더 데이터 로드
      final calendarJson = prefs.getString(_calendarKey);
      if (calendarJson != null) {
        final calendarData = Map<String, Map<String, dynamic>>.from(
          jsonDecode(calendarJson).map((key, value) => 
            MapEntry(key, Map<String, dynamic>.from(value))
          )
        );
        _calendarData.clear();
        _calendarData.addAll(calendarData);
      }
      
      // 소망 데이터 로드
      final wishesJson = prefs.getString(_wishesKey);
      if (wishesJson != null) {
        final wishesData = Map<String, List<Map<String, dynamic>>>.from(
          jsonDecode(wishesJson).map((key, value) => 
            MapEntry(key, List<Map<String, dynamic>>.from(
              (value as List).map((item) => Map<String, dynamic>.from(item))
            ))
          )
        );
        _persistentWishes.clear();
        _persistentWishes.addAll(wishesData);
      }
    } catch (e) {
    }
  }
  
  // 모든 데이터 삭제
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_calendarKey);
      await prefs.remove(_wishesKey);
      _calendarData.clear();
      _persistentWishes.clear();
    } catch (e) {
    }
  }
}

// --- 홈 화면 ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사
  int _currentEmotionIndex = 1; // 현재 표정 인덱스
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  
  // 음악 재생 관련
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  List<String> _musicPlaylist = [
    'audio/기다림.mp3',
    'audio/꿈속에서만나.mp3',
  ];
  int _currentMusicIndex = 0;
  
  
  // 알림 관련
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 애니메이션 관련
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;
  
  // 응원의 말 관련
  bool _showEncouragement = false;
  String _currentEncouragementMessage = '';
  
  // 시간대별 배경 이미지
  String _getBackgroundImage() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 10) {
      // 새벽 ~ 아침 (05:00 ~ 10:00)
      return 'assets/images/backgrounds/희망의일출.png';
    } else if (hour >= 10 && hour < 17) {
      // 낮 (10:00 ~ 17:00)
      return 'assets/images/backgrounds/평온한하늘.png';
    } else if (hour >= 17 && hour < 20) {
      // 저녁 (17:00 ~ 20:00)
      return 'assets/images/backgrounds/아름다운노을.png';
    } else {
      // 밤 (20:00 ~ 05:00)
      return 'assets/images/backgrounds/고요한별밤.png';
    }
  }
  
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

  // 응원의 말 목록
  final List<String> _encouragementMessages = [
    '정말 잘하고 있어요! 💪',
    '훌륭해요! 계속 이렇게 해요! ✨',
    '오늘도 멋진 하루를 보내고 있네요! 🌟',
    '정말 대단해요! 자랑스러워요! 👏',
    '완벽해요! 정말 잘했어요! 🎉',
    '오늘도 최고의 하루였어요! 🌈',
    '정말 멋진 선택이에요! 💖',
    '훌륭한 하루를 보내고 있네요! 🌸',
    '정말 자랑스러워요! 잘했어요! 🌺',
    '오늘도 멋진 하루였어요! 🌻',
    '정말 대단해요! 계속 이렇게 해요! 🌷',
    '완벽한 하루를 보내고 있네요! 🌹',
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeHeartAnimation();
    _initializeApp();
  }
  
  // 하트 애니메이션 초기화
  void _initializeHeartAnimation() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _heartOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showEncouragement = false;
        });
        _heartAnimationController.reset();
      }
    });
  }

  // 앱 초기화
  Future<void> _initializeApp() async {
    _initializeNotifications();
    _configureAudioPlayer();
    _scheduleDailyWishNotification(); // 매일 11시 47분 소망 설정 알림 스케줄링
    
    // 저장된 데이터 로드
    await _loadStoredData();
    
    // 일일 데이터 확인 및 관리
    await _checkAndManageDailyData();
  }

  // 저장된 데이터 로드
  Future<void> _loadStoredData() async {
    // 천사 데이터 로드
    await AngelDataManager.loadAngelFromStorage();
    
    // 캘린더 데이터 로드
    await CalendarDataManager.loadCalendarFromStorage();
    
    // 일일 데이터 날짜 로드
    final prefs = await SharedPreferences.getInstance();
    _lastDataDate = prefs.getString('last_data_date');
    
    // UI 업데이트
    if (mounted) {
      setState(() {});
    }
  }
  
  // 일일 데이터 확인 및 관리
  Future<void> _checkAndManageDailyData() async {
    final today = _getDateString(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    
    // 오늘 날짜와 마지막 데이터 날짜가 다르면 새로운 데이터 생성
    if (_lastDataDate != today) {
      // 새로운 목표와 감사 생성
      _generateRandomGoals();
      _generateRandomGratitudes();
      
      // 오늘 날짜로 업데이트
      _lastDataDate = today;
      await prefs.setString('last_data_date', today);
      
      // 목표와 감사 데이터 저장
      await _saveDailyData();
    } else {
      // 같은 날이면 저장된 데이터 로드
      await _loadDailyData();
    }
  }
  
  // 일일 데이터 저장
  Future<void> _saveDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_goals', jsonEncode(_goals));
    await prefs.setString('daily_gratitudes', jsonEncode(_gratitudes));
  }
  
  // 일일 데이터 로드
  Future<void> _loadDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final goalsJson = prefs.getString('daily_goals');
    if (goalsJson != null) {
      final List<dynamic> goalsList = jsonDecode(goalsJson);
      _goals = goalsList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    
    final gratitudesJson = prefs.getString('daily_gratitudes');
    if (gratitudesJson != null) {
      final List<dynamic> gratitudesList = jsonDecode(gratitudesJson);
      _gratitudes = gratitudesList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  // 랜덤 목표 생성 (기존 소망 내용을 목표로 사용)
  void _generateRandomGoals() {
    final random = Random();
    List<Map<String, dynamic>> newGoals = [];
    
    // test 목표들 추가
    newGoals.add({
      'text': 'test1',
      'completed': false,
      'category': 'test',
    });
    newGoals.add({
      'text': 'test2',
      'completed': false,
      'category': 'test',
    });
    newGoals.add({
      'text': 'test3',
      'completed': false,
      'category': 'test',
    });
    
    // 각 카테고리에서 1개씩 랜덤 선택
    _goalCategories.forEach((category, items) {
      final selectedItem = items[random.nextInt(items.length)];
      newGoals.add({
        'text': selectedItem,
        'completed': false,
        'category': category,
      });
    });
    
    setState(() {
      _goals = newGoals;
    });
    
    // 수동 새로고침일 때만 피드백 표시
    if (_lastDataDate == _getDateString(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('목표가 새로고침되었습니다! ✨'),
          backgroundColor: Colors.blue[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // 랜덤 감사 생성
  void _generateRandomGratitudes() {
    final random = Random();
    final gratitudeOptions = [
      '가족과 함께할 수 있어서',
      '맛있는 음식을 먹을 수 있어서',
      '건강한 몸을 가지고 있어서',
      '좋은 날씨에 감사해서',
      '친구들과의 만남에 감사해서서',
      '새로운 하루를 시작할 수 있어서',
      '사랑하는 사람들이 있어서',
      '평화로운 마음으로 잠들 수 있어서',
      '작은 기쁨들을 발견할 수 있어서',
      '하나님의 사랑을 느낄 수 있어서',
    ];

    List<Map<String, dynamic>> newGratitudes = [];

    // 3개 랜덤 선택 (중복 없이)
    List<String> selectedGratitudes = [];
    while (selectedGratitudes.length < 3) {
      final selected = gratitudeOptions[random.nextInt(gratitudeOptions.length)];
      if (!selectedGratitudes.contains(selected)) {
        selectedGratitudes.add(selected);
      }
    }

    for (String gratitude in selectedGratitudes) {
      newGratitudes.add({
        'text': gratitude,
        'completed': false,
      });
    }

    setState(() {
      _gratitudes = newGratitudes;
    });
    
    // 수동 새로고침일 때만 피드백 표시
    if (_lastDataDate == _getDateString(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('감사가 새로고침되었습니다! ✨'),
          backgroundColor: Colors.yellow[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  

  // 오디오 플레이어 설정 (알림 비활성화)
  Future<void> _configureAudioPlayer() async {
    // 간단한 설정으로 알림 최소화
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  // 음악 재생/일시정지 토글
  Future<void> _toggleMusic() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        // 알림 제거
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('🎵 음악이 일시정지되었습니다'),
        //     duration: Duration(seconds: 1),
        //   ),
        // );
      } else {
        await _playCurrentMusic();
      }
    } catch (e) {
      // 에러 알림도 제거
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('음악 재생에 실패했습니다'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    }
  }

  // 현재 음악 재생
  Future<void> _playCurrentMusic() async {
    try {
      final currentMusic = _musicPlaylist[_currentMusicIndex];
      
      // 알림 없이 재생
      await _audioPlayer.play(
        AssetSource(currentMusic),
        volume: 0.8,
        mode: PlayerMode.mediaPlayer,
      );
      
      setState(() {
        _isPlaying = true;
      });
      
      // 음악이 끝나면 다음 곡으로 자동 이동
      _audioPlayer.onPlayerComplete.listen((_) {
        _playNextMusic();
      });
      
      // SnackBar도 제거하여 알림 최소화
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('🎵 ${_getMusicName(currentMusic)} 재생 중'),
      //     duration: const Duration(seconds: 1),
      //   ),
      // );
    } catch (e) {
      // 로컬 파일이 없으면 시뮬레이션
      setState(() {
        _isPlaying = true;
      });
      // 시뮬레이션 알림도 제거
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('🎵 ${_getMusicName(_musicPlaylist[_currentMusicIndex])} 재생 모드 (시뮬레이션)'),
      //     duration: const Duration(seconds: 2),
      //   ),
      // );
    }
  }

  // 특정 음악 재생
  Future<void> _playMusic(int index) async {
    setState(() {
      _currentMusicIndex = index;
    });
    await _playCurrentMusic();
  }

  // 다음 곡 재생
  Future<void> _playNextMusic() async {
    setState(() {
      _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;
    });
    await _playCurrentMusic();
  }

  // 음악 이름 추출
  String _getMusicName(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll('.mp3', '').replaceAll('_', ' ');
  }

  // 알림 초기화
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 알림 권한 요청
    await _requestNotificationPermission();
  }

  // 알림 권한 요청
  Future<void> _requestNotificationPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 매일 오전 11시 47분에 소망 설정 알림 스케줄링
  Future<void> _scheduleDailyWishNotification() async {
    try {
      // 기존 알림 취소
      await _notifications.cancel(1);
      
      // 오늘 오전 11시 47분 시간 설정
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 11, 47);
      
      // 이미 지난 시간이면 내일로 설정
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      // 타임존 설정
      final location = tz.getLocation('Asia/Seoul');
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
      
      // 알림 스케줄링
      await _notifications.zonedSchedule(
        1, // 알림 ID
        '소망 설정 시간이에요! 🌟',
        '오늘의 소망을 설정해보세요',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_wish_channel',
            '일일 소망 알림',
            channelDescription: '매일 소망을 설정하도록 알려주는 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
        payload: 'daily_wish',
      );
    } catch (e) {
      // 정확한 알림 권한이 없거나 다른 에러가 발생한 경우 일반 알림으로 대체
      print('정확한 알림 스케줄링 실패, 일반 알림으로 대체: $e');
      try {
        await _notifications.zonedSchedule(
          1,
          '소망 설정 시간이에요! 🌟',
          '오늘의 소망을 설정해보세요',
          tz.TZDateTime.now(tz.getLocation('Asia/Seoul')).add(const Duration(minutes: 1)),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_wish_channel',
              '일일 소망 알림',
              channelDescription: '매일 소망을 설정하도록 알려주는 알림',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'daily_wish',
        );
      } catch (e2) {
        print('일반 알림 스케줄링도 실패: $e2');
      }
    }
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == 'daily_wish') {
      _showDailyWishDialog();
    }
  }


  // 일일 소망 설정 다이얼로그
  void _showDailyWishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WishDialog(
          currentCount: _wishes.length,
          onWishAdded: (wishText) {
            setState(() {
              _wishes.add({
                'text': wishText,
                'completed': false,
              });
            });
            _saveToCalendar(); // 캘린더에 저장
          },
        );
      },
    );
  }


  // 설정 다이얼로그 표시
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: bgColor,
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
                Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      l10n.settings,
                      style: const TextStyle(
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
                _buildSettingsItem(Icons.music_note, l10n.musicSettings, () {
                  Navigator.of(context).pop();
                  _showMusicSettingsDialog();
                }),
                _buildSettingsItem(Icons.language, l10n.languageSelection, () {
                  Navigator.of(context).pop();
                  _showLanguageSelectionDialog(context);
                }),
                _buildSettingsItem(Icons.notifications, l10n.notificationSettings, () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.notificationSettings} 기능 준비 중입니다')),
                  );
                }),
                _buildSettingsItem(Icons.palette, l10n.themeSettings, () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.themeSettings} 기능 준비 중입니다')),
                  );
                }),
                _buildSettingsItem(Icons.help, l10n.help, () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.help} 기능 준비 중입니다')),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 언어 선택 다이얼로그 표시
  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              minWidth: 300,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.languageSelection,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...LanguageManager.supportedLocales.map((locale) {
                    final isSelected = LanguageManager.currentLocale.languageCode == locale.languageCode;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? primaryColor : Colors.grey[200],
                          foregroundColor: isSelected ? Colors.white : textColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          await LanguageManager.setLanguage(locale);
                          Navigator.of(context).pop();
                          // 앱 전체 재시작을 위해 AngelDiaryApp으로 이동
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const AngelDiaryApp(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          LanguageManager.getLanguageName(locale),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 마이페이지 다이얼로그 표시
  void _showMyPageDialog() {
    final angelData = AngelDataManager.currentAngel;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgColor,
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
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.purple, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      '마이페이지',
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
                // 천사 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '나의 천사',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('이름: ${angelData?.name ?? '미설정'}'),
                      Text('특징: ${angelData?.feature ?? '미설정'}'),
                      Text('동물: ${angelData?.animalType ?? '미설정'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildMyPageItem(Icons.edit, '천사 커스터마이징', () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/customization');
                }),
                _buildMyPageItem(Icons.analytics, '통계 보기', () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('통계 기능 준비 중입니다')),
                  );
                }),
                _buildMyPageItem(Icons.backup, '데이터 백업', () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('백업 기능 준비 중입니다')),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 음악 설정 다이얼로그
  void _showMusicSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgColor,
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
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.pink, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      '음악 설정',
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
                const Text(
                  '플레이리스트',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ..._musicPlaylist.asMap().entries.map((entry) {
                  final index = entry.key;
                  final music = entry.value;
                  final isCurrent = index == _currentMusicIndex;
                  return GestureDetector(
                    onTap: () {
                      _playMusic(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent ? primaryColor.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent ? Border.all(color: primaryColor, width: 2) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCurrent ? Icons.play_arrow : Icons.music_note,
                            color: isCurrent ? primaryColor : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getMusicName(music),
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? primaryColor : Colors.grey[700],
                              ),
                            ),
                          ),
                          if (isCurrent && _isPlaying)
                            Icon(
                              Icons.volume_up,
                              color: primaryColor,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // 설정 아이템 빌더
  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[600], size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // 마이페이지 아이템 빌더
  Widget _buildMyPageItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple[600], size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
  
  // 목표 카테고리별 데이터 (기존 소망 내용을 목표로 이동)
  final Map<String, List<String>> _goalCategories = {
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
  
  List<Map<String, dynamic>> _goals = [];
  
  List<Map<String, dynamic>> _gratitudes = [
    {'text': '오늘 감사했던 일 3가지 자기 전에 떠올리기', 'completed': false},
    {'text': '하늘 한번 올려다보고 계절의 변화 느껴보기', 'completed': false},
    {'text': '가장 좋아하는 성경 구절이나 명언 한 줄 필사하기', 'completed': false},
  ];
  
  // 일일 데이터 관리
  String? _lastDataDate;

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
                // 상단 음악 버튼
                _buildMusicButton(),
                const SizedBox(height: 12),
                
                // 상단 말풍선 영역
                _buildSpeechBubble(),
                const SizedBox(height: 12),
                
                // 천사 일러스트 영역
                _buildAngelIllustration(),
                const SizedBox(height: 12),
                
                // 날짜와 기온 정보
                _buildDateWeatherInfo(),
                const SizedBox(height: 12),
                
                // 탭과 목록 영역
                _buildTabSection(),
                const SizedBox(height: 12),
                
                // 하단 섹션 (일기 쓰기 버튼 + 캘린더 아이콘)
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 음악 버튼 위젯
  Widget _buildMusicButton() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleMusic,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isPlaying ? Colors.pink[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying ? Icons.music_note : Icons.music_off,
                  color: _isPlaying ? Colors.pinkAccent : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isPlaying ? '음악 재생 중' : '음악 재생',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isPlaying ? Colors.pinkAccent : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 다음 곡 버튼
        GestureDetector(
          onTap: _playNextMusic,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.skip_next,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        // 설정 버튼
        GestureDetector(
          onTap: _showSettingsDialog,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 마이페이지 버튼
        GestureDetector(
          onTap: _showMyPageDialog,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: Colors.purple[600],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble() {
    final angelData = AngelDataManager.currentAngel;
    final angelName = angelData?.name ?? '천사';
    
    // 고정된 메시지 사용 (첫 번째 메시지)
    final fixedMessage = _messages[0];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              angelData != null 
                ? '$angelName와(과) 함께하는 따뜻한 하루가 되길 바라요.\n${fixedMessage['text']}\n- ${fixedMessage['source']}'
                : '당신의 마음속 사랑은\n시간과 공간을 넘어 전해진다.\n${fixedMessage['text']}\n- ${fixedMessage['source']}'
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
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 시간대별 배경 (맨 아래 레이어)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // 투명한 천사 이미지 (시간대별 배경 위에 쌓이는 레이어)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/backgrounds/crt_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // 천사 캐릭터 (중앙에서 살짝 아래로 배치)
          Positioned(
            left: 0,
            right: 0,
            top: 140, // 천사를 더 아래로 이동
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
          
          // 응원 문구 (하트 애니메이션 위치에 표시)
          if (_showEncouragement)
            Positioned(
              left: 20, // 오른쪽으로 이동
              right: 0,
              top: 100, // 천사 위쪽에 배치
              child: Center(
                child: AnimatedBuilder(
                  animation: _heartAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartScaleAnimation.value,
                      child: Opacity(
                        opacity: _heartOpacityAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _currentEncouragementMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildTabButton(0, '소망', Colors.lightBlue[300]!),
                _buildTabButton(1, '목표', Colors.pink[200]!),
                _buildTabButton(2, '감사', Colors.yellow[400]!),
              ],
            ),
          ),
          
          // 내용 영역
          Container(
            padding: const EdgeInsets.all(16),
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
                    if (_selectedTabIndex == 1) // 목표 탭일 때만 새로고침 버튼 표시
                      GestureDetector(
                        onTap: _generateRandomGoals,
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
          
                // 새 항목 추가 버튼 (모든 탭에서 동일)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed: _isAddButtonEnabled() ? _getAddButtonAction() : null,
                    icon: const Icon(Icons.add_circle_outline, size: 24),
                    label: Text(
                      _getAddButtonText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddButtonEnabled() ? _getTabColor() : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                
                // 목록 표시 (모든 탭에서 동일한 형태)
                  // 목표와 감사 탭의 기존 리스트
                ..._getCurrentList().asMap().entries.map((entry) {
                    final item = entry.value;
                    final isCompleted = item['completed'] as bool;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
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
                              color: _selectedTabIndex == 0 ? textColor : (isCompleted ? Colors.lightGreen : textColor),
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.normal : (isCompleted ? FontWeight.w600 : FontWeight.normal),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 수정 버튼
                        IconButton(
                          onPressed: () => _showEditDialog(entry.key),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        // 체크박스 (평생의 소망 탭에서는 숨김)
                        if (_selectedTabIndex != 0)
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

  // 하단 섹션 (일기 쓰기/수정 버튼 + 캘린더 아이콘)
  Widget _buildBottomSection() {
    final dateString = _getDateString(_selectedDate);
    final existingDiary = CalendarDataManager.getDiary(dateString);
    final hasDiary = existingDiary != null && existingDiary.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 일기 쓰기/수정 버튼 (왼쪽)
          Expanded(
            child: ElevatedButton(
              onPressed: hasDiary ? _showEditDiaryDialog : _showDiaryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasDiary ? Icons.edit : Icons.edit_note, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    hasDiary ? '오늘의 일기 수정' : '오늘의 일기 쓰기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 캘린더 아이콘 (오른쪽)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: _showCalendarDialog,
              icon: const Icon(
                Icons.calendar_today,
                size: 28,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 일기 다이얼로그 표시 (새로 작성)
  void _showDiaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiaryDialog();
      },
    );
  }

  // 일기 수정 다이얼로그 표시
  void _showEditDiaryDialog() {
    final dateString = _getDateString(_selectedDate);
    final existingContent = CalendarDataManager.getDiary(dateString);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiaryDialog(
          existingContent: existingContent,
          isEditMode: true,
        );
      },
    );
  }

  // 캘린더 다이얼로그 표시
  void _showCalendarDialog() {
    // 현재 데이터를 캘린더에 저장
    _saveToCalendar();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleCalendarDialog();
      },
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

  // 날짜와 기온 정보 위젯
  Widget _buildDateWeatherInfo() {
    final now = DateTime.now();
    final weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
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
                  color: textColor,
                ),
              ),
            ],
          ),
          
          // 기온 정보
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.orange[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기온: 25°C',
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


  String _getCurrentTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return '평생의 소망';
      case 1:
        return '오늘의 목표';
      case 2:
        return '오늘의 감사';
      default:
        return '평생의 소망';
    }
  }

  // 추가 버튼 텍스트
  String _getAddButtonText() {
    switch (_selectedTabIndex) {
      case 0:
        return '새 소망 추가하기 (${_wishes.length}/3)';
      case 1:
        return '새 목표 추가하기 (${_goals.length}/5)';
      case 2:
        return '새 감사 추가하기 (${_gratitudes.length}/5)';
      default:
        return '새 항목 추가하기';
    }
  }

  // 추가 버튼 액션
  VoidCallback _getAddButtonAction() {
    switch (_selectedTabIndex) {
      case 0:
        return _showWishDialog;
      case 1:
        return _showGoalDialog;
      case 2:
        return _showGratitudeDialog;
      default:
        return _showWishDialog;
    }
  }

  // 탭 색상
  Color _getTabColor() {
    switch (_selectedTabIndex) {
      case 0:
        return Colors.lightBlue[300]!;
      case 1:
        return Colors.pink[300]!;
      case 2:
        return Colors.yellow[300]!;
      default:
        return Colors.lightBlue[300]!;
    }
  }

  // 추가 버튼 활성화 여부
  bool _isAddButtonEnabled() {
    switch (_selectedTabIndex) {
      case 0:
        return _wishes.length < 3; // 소망은 최대 3개
      case 1:
        return _goals.length < 5; // 목표는 최대 5개
      case 2:
        return _gratitudes.length < 5; // 감사는 최대 5개
      default:
        return true;
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
      final wasCompleted = currentList[index]['completed'] as bool;
      currentList[index]['completed'] = !wasCompleted;
      
      // 선택된 날짜의 데이터를 캘린더에 저장
      _saveToCalendar();
      
      // 일일 데이터 저장 (목표나 감사 탭에서만)
      if (_selectedTabIndex == 1 || _selectedTabIndex == 2) {
        _saveDailyData();
        _showHeartAnimation(!wasCompleted); // 새로운 체크 상태 전달
      }
    });
  }
  
  // 응원 문구 애니메이션 시작
  void _showHeartAnimation(bool isCompleted) {
    _showEncouragementMessage(isCompleted);
    _heartAnimationController.forward();
  }
  
  
  // 응원의 말 표시
  void _showEncouragementMessage(bool isCompleted) {
    final random = Random();
    
    if (isCompleted) {
      // 체크했을 때의 응원 문구
      _currentEncouragementMessage = _encouragementMessages[random.nextInt(_encouragementMessages.length)];
    } else {
      // 체크 해제했을 때의 응원 문구
      final uncheckMessages = [
        '괜찮아요! 다시 도전해보세요! 💪',
        '아직 시간이 있어요! 천천히 해보세요! 🌱',
        '다음에 더 잘할 수 있을 거예요! 🌟',
        '조금씩 천천히 해보세요! 🌸',
        '포기하지 마세요! 응원해요! 🌺',
        '다시 한 번 도전해보세요! 🌻',
        '천천히 해도 괜찮아요! 🌷',
        '다음 기회에 더 잘할 거예요! 🌹',
      ];
      _currentEncouragementMessage = uncheckMessages[random.nextInt(uncheckMessages.length)];
    }
    
    setState(() {
      _showEncouragement = true;
    });
    
    // 3초 후 응원의 말 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showEncouragement = false;
        });
      }
    });
  }

  // 수정 다이얼로그 표시
  void _showEditDialog(int index) {
    final currentList = _getCurrentList();
    final item = currentList[index];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(
          initialText: item['text'] as String,
          tabIndex: _selectedTabIndex,
          onItemEdited: (newText) {
            setState(() {
              currentList[index]['text'] = newText;
            });
            _saveToCalendar();
          },
        );
      },
    );
  }

  // 선택된 날짜의 데이터를 캘린더에 저장
  Future<void> _saveToCalendar() async {
    final dateString = _getDateString(_selectedDate);
    
    final dayData = {
      'wishes': List<Map<String, dynamic>>.from(_wishes),
      'goals': List<Map<String, dynamic>>.from(_goals),
      'gratitudes': List<Map<String, dynamic>>.from(_gratitudes),
      'diary': CalendarDataManager.getDiary(dateString) ?? '',
    };
    
    // 전역 캘린더 데이터에 저장
    await CalendarDataManager.saveDayData(dateString, dayData);
    
    // 소망도 별도로 저장 (지속적 유지를 위해)
    await CalendarDataManager.saveWishes(dateString, _wishes);
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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



  // 소망 추가 다이얼로그
  void _showWishDialog() {
    // 최대 3개 제한 확인
    if (_wishes.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('소망은 최대 3개까지 추가할 수 있습니다 💙'),
          backgroundColor: Colors.lightBlue[600],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WishDialog(
          currentCount: _wishes.length,
          onWishAdded: (wishText) {
            setState(() {
              _wishes.add({
                'text': wishText,
                'completed': false,
              });
            });
            _saveToCalendar();
            // 소망도 별도로 저장
            final dateString = _getDateString(_selectedDate);
            CalendarDataManager.saveWishes(dateString, _wishes);
          },
        );
      },
    );
  }

  // 목표 추가 다이얼로그
  void _showGoalDialog() {
    // 최대 5개 제한 확인
    if (_goals.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('목표는 최대 5개까지 추가할 수 있습니다 💖'),
          backgroundColor: Colors.pink[600],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GoalDialog(
          currentCount: _goals.length,
          onGoalAdded: (goalText) {
            setState(() {
              _goals.add({
                'text': goalText,
                'completed': false,
              });
            });
            _saveToCalendar();
          },
        );
      },
    );
  }

  // 감사 추가 다이얼로그
  void _showGratitudeDialog() {
    // 최대 5개 제한 확인
    if (_gratitudes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('감사는 최대 5개까지 추가할 수 있습니다 💛'),
          backgroundColor: Colors.yellow[600],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GratitudeDialog(
          currentCount: _gratitudes.length,
          onGratitudeAdded: (gratitudeText) {
            setState(() {
              _gratitudes.add({
                'text': gratitudeText,
                'completed': false,
              });
            });
            _saveToCalendar();
          },
        );
      },
    );
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
      backgroundColor: bgColor,
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
      backgroundColor: bgColor,
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

// 일일 소망 설정 다이얼로그 위젯
class DailyWishDialog extends StatefulWidget {
  final List<String> currentWishes;
  final Function(List<String>) onWishesSaved;

  const DailyWishDialog({
    super.key,
    required this.currentWishes,
    required this.onWishesSaved,
  });

  @override
  State<DailyWishDialog> createState() => _DailyWishDialogState();
}

class _DailyWishDialogState extends State<DailyWishDialog> {
  final List<TextEditingController> _controllers = [];
  final int maxWishes = 5;

  @override
  void initState() {
    super.initState();
    // 기존 소망들을 컨트롤러에 추가
    for (int i = 0; i < maxWishes; i++) {
      _controllers.add(TextEditingController(
        text: i < widget.currentWishes.length ? widget.currentWishes[i] : '',
      ));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.lightBlue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  '오늘의 소망 설정',
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
            const SizedBox(height: 8),
            Text(
              '최대 5개까지 소망을 설정할 수 있습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // 소망 입력 필드들
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(maxWishes, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.pink[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              decoration: InputDecoration(
                                hintText: '소망 ${index + 1}을 입력하세요',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.pink[400]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
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
                    onPressed: _saveWishes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _saveWishes() {
    final wishes = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    widget.onWishesSaved(wishes);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${wishes.length}개의 소망이 저장되었습니다! 💙'),
        backgroundColor: Colors.lightBlue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 소망 추가 다이얼로그
class WishDialog extends StatefulWidget {
  final int currentCount;
  final Function(String) onWishAdded;

  const WishDialog({
    super.key,
    required this.currentCount,
    required this.onWishAdded,
  });

  @override
  State<WishDialog> createState() => _WishDialogState();
}

class _WishDialogState extends State<WishDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.lightBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '새 소망 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '현재 ${widget.currentCount}/3개',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '소망을 입력해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.lightBlue[400]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
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
                    onPressed: _saveWish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _saveWish() {
    final wishText = _controller.text.trim();
    
    if (wishText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소망을 입력해주세요')),
      );
      return;
    }
    
    widget.onWishAdded(wishText);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('소망이 추가되었습니다! 💙'),
        backgroundColor: Colors.lightBlue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 목표 추가 다이얼로그
class GoalDialog extends StatefulWidget {
  final int currentCount;
  final Function(String) onGoalAdded;

  const GoalDialog({
    super.key,
    required this.currentCount,
    required this.onGoalAdded,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.flag, color: Colors.pink[300]!, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '새 목표 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '현재 ${widget.currentCount}/3개',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '목표를 입력해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink[400]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
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
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _saveGoal() {
    final goalText = _controller.text.trim();
    
    if (goalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표를 입력해주세요')),
      );
      return;
    }
    
    widget.onGoalAdded(goalText);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('목표가 추가되었습니다! 💖'),
        backgroundColor: Colors.pink[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 감사 추가 다이얼로그
class GratitudeDialog extends StatefulWidget {
  final int currentCount;
  final Function(String) onGratitudeAdded;

  const GratitudeDialog({
    super.key,
    required this.currentCount,
    required this.onGratitudeAdded,
  });

  @override
  State<GratitudeDialog> createState() => _GratitudeDialogState();
}

class _GratitudeDialogState extends State<GratitudeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.yellow[600], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '새 감사 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '현재 ${widget.currentCount}/3개',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '감사한 것을 입력해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.yellow[400]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
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
                    onPressed: _saveGratitude,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _saveGratitude() {
    final gratitudeText = _controller.text.trim();
    
    if (gratitudeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('감사한 것을 입력해주세요')),
      );
      return;
    }
    
    widget.onGratitudeAdded(gratitudeText);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('감사가 추가되었습니다! 💛'),
        backgroundColor: Colors.yellow[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 수정 다이얼로그
class EditDialog extends StatefulWidget {
  final String initialText;
  final int tabIndex;
  final Function(String) onItemEdited;

  const EditDialog({
    super.key,
    required this.initialText,
    required this.tabIndex,
    required this.onItemEdited,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.tabIndex) {
      case 0:
        return '소망 수정';
      case 1:
        return '목표 수정';
      case 2:
        return '감사 수정';
      default:
        return '항목 수정';
    }
  }

  IconData _getIcon() {
    switch (widget.tabIndex) {
      case 0:
        return Icons.favorite;
      case 1:
        return Icons.flag;
      case 2:
        return Icons.favorite_border;
      default:
        return Icons.edit;
    }
  }

  Color _getColor() {
    switch (widget.tabIndex) {
      case 0:
        return Colors.lightBlue[300]!;
      case 1:
        return Colors.pink[300]!;
      case 2:
        return Colors.yellow[600]!;
      default:
        return Colors.grey;
    }
  }

  String _getHintText() {
    switch (widget.tabIndex) {
      case 0:
        return '소망을 수정해주세요...';
      case 1:
        return '목표를 수정해주세요...';
      case 2:
        return '감사한 것을 수정해주세요...';
      default:
        return '내용을 수정해주세요...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(_getIcon(), color: _getColor(), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getColor()),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
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
                    onPressed: _saveEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getColor(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _saveEdit() {
    final newText = _controller.text.trim();
    
    if (newText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요')),
      );
      return;
    }
    
    widget.onItemEdited(newText);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getTitle()}이 완료되었습니다!'),
        backgroundColor: _getColor(),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
