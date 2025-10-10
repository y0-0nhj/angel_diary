import 'package:flutter/material.dart';
import 'main.dart';
import 'home.dart';
import 'services/daily.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 간단한 캘린더 다이얼로그
class SimpleCalendarDialog extends StatefulWidget {
  const SimpleCalendarDialog({super.key});

  @override
  _SimpleCalendarDialogState createState() => _SimpleCalendarDialogState();
}

class _SimpleCalendarDialogState extends State<SimpleCalendarDialog> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedDayData;
  int _selectedTabIndex = 0; // 0: 목표, 1: 감사

  @override
  void initState() {
    super.initState();
    _loadDayData(_selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다이얼로그가 다시 포커스될 때마다 최신 데이터 로드
    _loadDayData(_selectedDate);
  }

  void _loadDayData(DateTime date) async {
    final dateString = _getDateString(date);

    // 1. 먼저 SharedPreferences에서 로컬 데이터 확인
    final localData = CalendarDataManager.getDayData(dateString);

    if (localData != null && _hasValidData(localData)) {
      // 로컬에 유효한 데이터가 있으면 사용
      setState(() {
        _selectedDayData = localData;
      });
    } else {
      // 2. 로컬에 데이터가 없으면 Supabase에서 로드
      await _loadFromSupabase(dateString);
    }
  }

  bool _hasValidData(Map<String, dynamic> data) {
    // 목표, 감사, 일기 중 하나라도 있으면 유효한 데이터로 간주
    final goals = data['goals'] as List?;
    final gratitudes = data['gratitudes'] as List?;
    final diary = data['diary'] as String?;

    return (goals != null && goals.isNotEmpty) ||
        (gratitudes != null && gratitudes.isNotEmpty) ||
        (diary != null && diary.isNotEmpty);
  }

  Future<void> _loadFromSupabase(String dateString) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // 로그인되지 않은 경우 빈 데이터 표시
        setState(() {
          _selectedDayData = {
            'goals': <Map<String, dynamic>>[],
            'gratitudes': <Map<String, dynamic>>[],
            'diary': '',
          };
        });
        return;
      }

      final dailyRepo = DailyRepository();
      final date = DateTime.parse(dateString);
      final daily = await dailyRepo.getByDate(date);

      if (daily != null) {
        // Supabase 데이터를 로컬 형식으로 변환
        final Map<String, dynamic> convertedData = {
          'goals': <Map<String, dynamic>>[],
          'gratitudes': <Map<String, dynamic>>[],
          'diary': daily.diary ?? '',
        };

        // 목표 데이터 변환
        if (daily.goal != null && daily.goal!['items'] != null) {
          final goalItems = daily.goal!['items'] as List<dynamic>? ?? [];
          convertedData['goals'] = goalItems
              .map(
                (item) => {
                  'text': item['text'] ?? '',
                  'completed': item['completed'] ?? false,
                },
              )
              .toList();
        }

        // 감사 데이터 변환
        if (daily.gratitude != null && daily.gratitude!['items'] != null) {
          final gratitudeItems =
              daily.gratitude!['items'] as List<dynamic>? ?? [];
          convertedData['gratitudes'] = gratitudeItems
              .map(
                (item) => {
                  'text': item['text'] ?? '',
                  'completed': item['completed'] ?? false,
                },
              )
              .toList();
        }

        setState(() {
          _selectedDayData = convertedData;
        });
      } else {
        // Supabase에도 데이터가 없는 경우
        setState(() {
          _selectedDayData = {
            'goals': <Map<String, dynamic>>[],
            'gratitudes': <Map<String, dynamic>>[],
            'diary': '',
          };
        });
      }
    } catch (e) {
      print('Supabase에서 데이터 로드 실패: $e');
      // 에러 발생 시 빈 데이터 표시
      setState(() {
        _selectedDayData = {
          'goals': <Map<String, dynamic>>[],
          'gratitudes': <Map<String, dynamic>>[],
          'diary': '',
        };
      });
    }
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  // 반응형 헤더 빌더 (버튼들만)
  Widget _buildResponsiveHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // 폴드4 펼쳐진 상태 기준

    if (isWideScreen) {
      // 펼쳐진 상태: Row로 쭉 spaceBetween
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              _loadDayData(_selectedDate);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('데이터를 새로고침했습니다 ✨'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh, color: primaryColor),
            tooltip: '데이터 새로고침',
          ),
          // 날짜 선택 버튼
          ElevatedButton(
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
        ],
      );
    } else {
      // 접힌 상태: Wrap으로 줄바꿈
      return Wrap(
        alignment: WrapAlignment.end,
        children: [
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              _loadDayData(_selectedDate);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('데이터를 새로고침했습니다 ✨'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh, color: primaryColor),
            tooltip: '데이터 새로고침',
          ),
          // 날짜 선택 버튼
          ElevatedButton(
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
        ],
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTabIndex = 0; // 날짜 변경 시 목표 탭으로 초기화
      });
      _loadDayData(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: 300,
          minHeight: 400,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  const Text(
                    '캘린더',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Spacer(),
                  // 새로고침 버튼
                  IconButton(
                    onPressed: () {
                      _loadDayData(_selectedDate);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('데이터를 새로고침했습니다 ✨'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: primaryColor),
                    tooltip: '데이터 새로고침',
                  ),
                  // 날짜 선택 버튼
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 날짜 선택 영역
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // 화살표 날짜 탐색
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 왼쪽 화살표
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              final newDate = _selectedDate.subtract(
                                const Duration(days: 1),
                              );
                              setState(() {
                                _selectedDate = newDate;
                              });
                              _loadDayData(newDate);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.chevron_left,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 현재 날짜 표시
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_getWeekdayName(_selectedDate)}요일',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 오른쪽 화살표
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              final newDate = _selectedDate.add(
                                const Duration(days: 1),
                              );
                              setState(() {
                                _selectedDate = newDate;
                              });
                              _loadDayData(newDate);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 하단 영역 (상단: 소망/목표/감사, 하단: 일기)
              Column(
                children: [
                  // 상단: 소망/목표/감사 탭 영역
                  Container(
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
                    child: Column(
                      children: [
                        // 탭 버튼들
                        Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton(0, '목표', Colors.pink[200]!),
                              _buildTabButton(1, '감사', Colors.yellow[400]!),
                            ],
                          ),
                        ),

                        // 탭 내용
                        SizedBox(
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTabContent(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 하단: 일기 영역
                  Container(
                    width: double.infinity, // 상단 탭과 동일한 너비로 설정
                    height: 200,
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 일기',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            // Container 대신 Expanded 사용하여 남은 공간 모두 사용
                            child: SingleChildScrollView(
                              child: _buildDiaryContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryContent() {
    final String? diary = _selectedDayData?['diary'] as String?;

    if (diary == null || diary.isEmpty) {
      return SizedBox(
        width: double.infinity, // 전체 너비 사용
        child: Center(
          child: Text(
            '일기가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity, // 전체 너비 사용
      child: Text(
        diary,
        style: const TextStyle(fontSize: 16, color: textColor, height: 1.6),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, Color color) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
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

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSimpleDataList(_selectedDayData?['goals']);
      case 1:
        return _buildSimpleDataList(_selectedDayData?['gratitudes']);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSimpleDataList(dynamic data) {
    final List<Map<String, dynamic>> items = data != null
        ? List<Map<String, dynamic>>.from(data)
        : [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              '데이터가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
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
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Row(
            children: [
              Icon(
                item['completed']
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: item['completed'] ? Colors.lightGreen : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['text'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    decoration: item['completed'] == true
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
