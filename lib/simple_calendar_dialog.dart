import 'package:flutter/material.dart';
import 'main.dart';
import 'home.dart';

// 간단한 캘린더 다이얼로그
class SimpleCalendarDialog extends StatefulWidget {
  @override
  _SimpleCalendarDialogState createState() => _SimpleCalendarDialogState();
}

class _SimpleCalendarDialogState extends State<SimpleCalendarDialog> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedDayData;
  int _selectedTabIndex = 0; // 0: 소망, 1: 목표, 2: 감사

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

  void _loadDayData(DateTime date) {
    final dateString = _getDateString(date);
    setState(() {
      _selectedDayData = CalendarDataManager.getDayData(dateString);
    });
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
        _selectedTabIndex = 0; // 날짜 변경 시 소망 탭으로 초기화
      });
      _loadDayData(picked);
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
        height: MediaQuery.of(context).size.height * 0.8,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 현재 선택된 날짜 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '선택된 날짜',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    // 버튼들
                    Row(
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
                        ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          label: const Text(
                            '날짜 선택',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                              _buildTabButton(0, '소망', Colors.lightBlue[300]!),
                              _buildTabButton(1, '목표', Colors.pink[200]!),
                              _buildTabButton(2, '감사', Colors.yellow[400]!),
                            ],
                          ),
                        ),
                        
                        // 탭 내용
                        Container(
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
                          Expanded( // Container 대신 Expanded 사용하여 남은 공간 모두 사용
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
      return Container(
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
    
    return Container(
      width: double.infinity, // 전체 너비 사용
      child: Text(
        diary,
        style: const TextStyle(
          fontSize: 16,
          color: textColor,
          height: 1.6,
        ),
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
        return _buildSimpleDataList(_selectedDayData?['wishes']);
      case 1:
        return _buildSimpleDataList(_selectedDayData?['goals']);
      case 2:
        return _buildSimpleDataList(_selectedDayData?['gratitudes']);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSimpleDataList(dynamic data) {
    final List<Map<String, dynamic>> items = data != null ? List<Map<String, dynamic>>.from(data) : [];
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
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
            border: Border.all(
              color: Colors.transparent,
              width: 0,
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
                  item['text'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    decoration: item['completed'] == true ? TextDecoration.lineThrough : null,
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