import 'package:flutter/material.dart';
import 'main.dart';
import 'home.dart';
import 'services/daily.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 일기 다이얼로그
class DiaryDialog extends StatefulWidget {
  final String? existingContent;
  final bool isEditMode;

  const DiaryDialog({super.key, this.existingContent, this.isEditMode = false});

  @override
  _DiaryDialogState createState() => _DiaryDialogState();
}

class _DiaryDialogState extends State<DiaryDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 수정 모드일 때 기존 내용을 텍스트 필드에 미리 채우기
    if (widget.isEditMode && widget.existingContent != null) {
      _controller.text = widget.existingContent!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 반응형 헤더 빌더
  Widget _buildResponsiveHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // 폴드4 펼쳐진 상태 기준

    if (isWideScreen) {
      // 펼쳐진 상태: Row로 쭉 spaceBetween
      return Row(
        children: [
          const Icon(Icons.edit_note, color: primaryColor, size: 28),
          const SizedBox(width: 12),
          Text(
            widget.isEditMode ? '일기 수정하기' : '오늘의 일기',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      );
    } else {
      // 접힌 상태: Wrap으로 줄바꿈
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Flexible(
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  widget.isEditMode ? '일기 수정하기' : '오늘의 일기',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minWidth: 300,
          minHeight: 300,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              _buildResponsiveHeader(),
              const SizedBox(height: 20),

              // 날짜 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 일기 입력 영역
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '오늘 하루는 어땠나요?\n소중한 순간들을 기록해보세요...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(widget.isEditMode ? '수정하기' : '저장'),
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

  Future<void> _saveDiary() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일기 내용을 입력해주세요')));
      return;
    }

    try {
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 로컬에 일기 저장
      await CalendarDataManager.saveDiary(dateString, content);

      // Supabase에 목표, 감사, 일기 저장
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final dailyRepo = DailyRepository();

        // 오늘의 목표와 감사 데이터 가져오기
        final dayData = CalendarDataManager.getDayData(dateString);
        final goals = dayData?['goals'] as List<dynamic>? ?? [];
        final gratitudes = dayData?['gratitudes'] as List<dynamic>? ?? [];

        // 목표와 감사를 JSONB 형태로 변환
        Map<String, dynamic>? goalData;
        Map<String, dynamic>? gratitudeData;

        if (goals.isNotEmpty) {
          goalData = {
            'items': goals
                .map(
                  (goal) => {
                    'text': goal['text'] ?? '',
                    'completed': goal['completed'] ?? false,
                  },
                )
                .toList(),
          };
        }

        if (gratitudes.isNotEmpty) {
          gratitudeData = {
            'items': gratitudes
                .map(
                  (gratitude) => {
                    'text': gratitude['text'] ?? '',
                    'completed': gratitude['completed'] ?? false,
                  },
                )
                .toList(),
          };
        }

        // Supabase에 저장
        await dailyRepo.createOrUpsert(
          date: now,
          goal: goalData,
          gratitude: gratitudeData,
          diary: content,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditMode ? '일기가 수정되었습니다 ✨' : '일기가 저장되었습니다 ✨'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('일기 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
