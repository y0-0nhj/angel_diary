import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../utils/responsive_layout.dart' show FixedWidthLayout;
import '../../../main.dart' show bgColor;
import '../../../diary_dialog.dart';
import '../../../simple_calendar_dialog.dart';
import '../../angel/services/angel_service.dart';
import '../../calendar/models/calendar_entry_model.dart';
import '../../calendar/services/calendar_service.dart';
import '../widgets/angel_illustration.dart';
import '../widgets/bottom_section.dart';
import '../widgets/date_weather_info.dart';
import '../widgets/music_button.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/tab_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사
  int _currentEmotionIndex = 1; // 현재 표정 인덱스
  final DateTime _selectedDate = DateTime.now(); // 선택된 날짜

  // 음악 재생 관련
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final List<String> _musicPlaylist = ['audio/기다림.mp3', 'audio/꿈속에서만나.mp3'];
  int _currentMusicIndex = 0;

  // 알림 관련
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 애니메이션 관련
  late AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _heartAnimationController.dispose();
    _notifications.cancelAll();
    super.dispose();
  }

  void _initializeHeartAnimation() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> _initializeApp() async {
    _initializeHeartAnimation();
    _initializeNotifications();
    _configureAudioPlayer();
  }

  void _initializeNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notifications.initialize(initializationSettings);
  }

  void _configureAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNextMusic();
    });
  }

  void _toggleMusic() {
    setState(() {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _playCurrentMusic();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _playCurrentMusic() async {
    await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
  }

  void _playNextMusic() {
    setState(() {
      _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;
    });
    if (_isPlaying) {
      _playCurrentMusic();
    }
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showDiaryDialog([CalendarEntry? entry]) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiaryDialog(
          existingContent: entry?.diary,
          isEditMode: entry != null,
        );
      },
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleCalendarDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateString = _getDateString(_selectedDate);

    return FutureBuilder<CalendarEntry?>(
      future: CalendarService.getEntry(dateString),
      builder: (context, snapshot) {
        final hasDiary =
            snapshot.hasData &&
            snapshot.data?.diary != null &&
            snapshot.data!.diary!.isNotEmpty;

        return Scaffold(
          body: FixedWidthLayout(
            contentColor: bgColor,
            child: SafeArea(
              child: Column(
                children: [
                  // 상단 음악 버튼
                  MusicButton(
                    isPlaying: _isPlaying,
                    onToggle: _toggleMusic,
                    onNext: _playNextMusic,
                  ),
                  const SizedBox(height: 12),

                  // 상단 말풍선 영역
                  SpeechBubble(angelData: AngelService.currentAngel),
                  const SizedBox(height: 12),

                  // 천사 일러스트 영역
                  AngelIllustration(
                    angelData: AngelService.currentAngel,
                    emotionIndex: _currentEmotionIndex,
                    onEmotionChanged: (newEmotionIndex) {
                      setState(() {
                        _currentEmotionIndex = newEmotionIndex;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 날짜와 기온 정보
                  const DateWeatherInfo(),
                  const SizedBox(height: 12),

                  // 탭과 목록 영역
                  TabSection(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 하단 섹션 (일기 쓰기 버튼 + 캘린더 아이콘)
                  BottomSection(
                    hasDiary: hasDiary,
                    onDiaryEdit: () =>
                        _showDiaryDialog(hasDiary ? snapshot.data : null),
                    onCalendarTap: _showCalendarDialog,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (나머지 메서드들은 그대로 유지)
}
