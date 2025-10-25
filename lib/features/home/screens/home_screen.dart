// 홈 화면. Provider를 사용하여 상태를 관리합니다.
// - Provider를 통해 음악, 천사, 탭 상태를 관리
// - Consumer를 사용하여 필요한 부분만 리빌드
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../utils/responsive_layout.dart' show FixedWidthLayout;
import '../../../main.dart' show bgColor;
import '../../../diary_dialog.dart';
import '../../../simple_calendar_dialog.dart';
import '../../../providers/angel_provider.dart';
import '../../../providers/music_provider.dart';
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
/// Provider를 사용하여 상태를 관리하고 Consumer를 통해 UI를 업데이트합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사
  int _currentEmotionIndex = 1; // 현재 표정 인덱스
  final DateTime _selectedDate = DateTime.now(); // 선택된 날짜

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

  /// 화면 초기화 루틴: 애니메이션/알림을 설정합니다.
  Future<void> _initializeApp() async {
    _initializeHeartAnimation();
    _initializeNotifications();
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
                  // 상단 음악 버튼 (Provider 사용)
                  Consumer<MusicProvider>(
                    builder: (context, musicProvider, child) {
                      return MusicButton(
                        isPlaying: musicProvider.isPlaying,
                        onToggle: () => musicProvider.toggleMusic(),
                        onNext: () => musicProvider.playNext(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 상단 말풍선 영역 (Provider 사용)
                  Consumer<AngelProvider>(
                    builder: (context, angelProvider, child) {
                      return SpeechBubble(
                        angelData: angelProvider.currentAngel,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 천사 일러스트 영역 (Provider 사용)
                  Consumer<AngelProvider>(
                    builder: (context, angelProvider, child) {
                      return AngelIllustration(
                        angelData: angelProvider.currentAngel,
                        emotionIndex: _currentEmotionIndex,
                        onEmotionChanged: (newEmotionIndex) {
                          setState(() {
                            _currentEmotionIndex = newEmotionIndex;
                          });
                          // Provider에도 감정 업데이트
                          angelProvider.updateEmotion(newEmotionIndex);
                        },
                      );
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
