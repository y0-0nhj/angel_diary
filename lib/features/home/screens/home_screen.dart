// 홈 화면. 음악/말풍선/캐릭터/날씨/탭/하단 액션을 하나의 레이아웃에 배치합니다.
// - 상태: 탭 인덱스, 현재 감정, 선택 날짜, 음악 재생 상태, 재생목록 인덱스
// - 초기화: 알림 플러그인, 오디오 플레이어 설정, 심장 애니메이션 컨트롤러
// - 데이터: 캘린더 서비스에서 오늘 일기 존재 여부 조회
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

/// 앱의 메인 UI를 구성하는 홈 화면 위젯입니다.
///
/// 상단 음악 제어, 말풍선(대화), 캐릭터 일러스트, 날씨/날짜, 탭 콘텐츠,
/// 하단 일기/캘린더 액션으로 구성됩니다.
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

  /// 하트(감정 변화) 관련 애니메이션 컨트롤러 초기화
  void _initializeHeartAnimation() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  /// 화면 초기화 루틴: 애니메이션/알림/오디오 리스너를 설정합니다.
  Future<void> _initializeApp() async {
    _initializeHeartAnimation();
    _initializeNotifications();
    _configureAudioPlayer();
  }

  /// 로컬 알림 플러그인 초기화.
  void _initializeNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notifications.initialize(initializationSettings);
  }

  /// 오디오 플레이어의 재생 완료 이벤트를 구독하여 다음 곡으로 자연 전환합니다.
  void _configureAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNextMusic();
    });
  }

  /// 재생/일시정지를 토글합니다. 토글 직후 상태를 동기적으로 반영합니다.
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

  /// 현재 인덱스의 에셋 음악을 재생합니다.
  void _playCurrentMusic() async {
    await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
  }

  /// 재생목록을 순환하며 다음 곡으로 이동합니다. 재생 중인 경우 즉시 재생합니다.
  void _playNextMusic() {
    setState(() {
      _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;
    });
    if (_isPlaying) {
      _playCurrentMusic();
    }
  }

  /// DateTime을 'YYYY-MM-DD' 포맷 문자열로 변환합니다.
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 일기 작성/수정 다이얼로그를 표시합니다.
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

  /// 간단 캘린더 다이얼로그를 표시합니다.
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
