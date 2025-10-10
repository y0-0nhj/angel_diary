import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart' show bgColor, textColor;

/// 편지 쓰기 다이얼로그
///
/// 사용자가 편지를 작성하고 보낼 수 있는 다이얼로그입니다.
class LetterWritingDialog extends StatefulWidget {
  const LetterWritingDialog({super.key});

  @override
  _LetterWritingDialogState createState() => _LetterWritingDialogState();
}

class _LetterWritingDialogState extends State<LetterWritingDialog> {
  final TextEditingController _letterController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String _selectedEmotion = '😊'; // 기본 표정

  final List<String> _emotions = [
    '😊',
    '😢',
    '😍',
    '🤔',
    '😴',
    '😤',
    '🥰',
    '😭',
  ];

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
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
                  '받는 이',
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
                SizedBox(
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
                            color: isSelected
                                ? Colors.red[100]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey[300]!,
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
                  maxLines: 4,
                  minLines: 4,
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

                // 편지 목록 보기 버튼
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: _showLetterList,
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('편지 목록 보기'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

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
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
        ),
      ),
    );
  }

  /// 편지 보내기 기능
  void _sendLetter() async {
    if (_recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('받는 이를 입력해주세요.')));
      return;
    }

    if (_letterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('편지 내용을 입력해주세요.')));
      return;
    }

    try {
      // 편지 데이터 생성
      final letterData = {
        'recipient': _recipientController.text.trim(),
        'content': _letterController.text.trim(),
        'emotion': _selectedEmotion,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // SharedPreferences에서 기존 편지 목록 가져오기
      final prefs = await SharedPreferences.getInstance();
      final existingLetters = prefs.getStringList('letters') ?? [];

      // 새 편지 추가
      existingLetters.add(jsonEncode(letterData));

      // 저장 (최대 50개 편지까지만 보관)
      if (existingLetters.length > 50) {
        existingLetters.removeAt(0); // 가장 오래된 편지 제거
      }

      await prefs.setStringList('letters', existingLetters);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_recipientController.text}님에게 편지를 보냈습니다! 💌'),
          backgroundColor: Colors.lightGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('편지 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 편지 목록 보기 기능
  void _showLetterList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final letters = prefs.getStringList('letters') ?? [];

      // 개발자 편지 추가 (항상 첫 번째에 표시)
      final developerLetter = {
        'recipient': '천사일기 사용자님',
        'content':
            '안녕하세요! 천사일기 개발자입니다. 이 앱을 이용해주셔서 정말 감사합니다. 이 편지를 통해 저의 솔직한 이야기를 나누고 싶습니다. 저는 급작스럽게 발병한 뇌질환을 겪으면서 예측할 수 없는 감정의 폭풍과 끝없는 무기력감 속에서 모든 것을 포기하고 싶고 매일을 누워서 폰만하던 시간 속에 살았습니다. 제 안에 빛이 완전히 사라진 것만 같았고, 그 속에서 저는 자신감도 잃고 행복감도 잃었습니다. 그럼에도 불구하고 저에겐 6마리의 고양이들이 있었습니다. 게으름도 물리치고 끼니를 챙겨주고, 똥을 치워주는 일을 하게 해주던 소중한 아이들이었습니다. 그러다 문득 이 아이들이 언젠가 무지개다리를 건널 수 있다는 생각에 절망에 빠졌습니다. 그 때, 하나님을 만났습니다. 하나님께서는 소중한 아이들과 함께 주인을 기다리고있다고하셨습니다. 저는 남아있는 저를 위해서도, 무지개다리를 건넌 아이들을 보고싶어하시는 펫로스분들을 위해서도 그리움이 아닌 따뜻한 교감으로 가상에서도 아이들과 연결되어 함께 무기력과 공허를 극복할 수 있기를 간절히 바라는 마음으로 어플을 개발했습니다. 그것은 사랑이었습니다. 그 사랑은 저에게 다시 일어설 용기를 주었고, 그렇게 얻은 힘으로 저는 저의 모든 소망과 감사함을 기록하고싶어졌습니다. 그리고 저와 같은 어려움을 겪는 분들에게도 이 따뜻한 경험을 선물하고 싶다는 간절한 마음으로 이 <천사일기> 어플을 개발하게 되었습니다. 이는 저의 치유와 성장의 여정이자, 당신의 여정이 될 것입니다. 당신의 빛나는 소망을 천사일기와 함께 시작하세요!💙',
        'emotion': '😊',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'isDeveloper': true,
      };

      // 편지 목록에 개발자 편지 추가
      final allLetters = [jsonEncode(developerLetter), ...letters];

      // 편지 목록 다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('편지 목록'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: allLetters.length,
                itemBuilder: (context, index) {
                  final letterData = jsonDecode(allLetters[index]);
                  final createdAt = DateTime.parse(letterData['createdAt']);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: letterData['isDeveloper'] == true
                        ? Colors.blue[50]
                        : null,
                    child: ListTile(
                      leading: Text(
                        letterData['emotion'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        letterData['recipient'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: letterData['isDeveloper'] == true
                              ? Colors.blue[700]
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (letterData['isDeveloper'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '개발자 편지',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            letterData['content'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showLetterDetail(letterData);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('편지 목록을 불러오는 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 편지 상세 보기 기능
  void _showLetterDetail(Map<String, dynamic> letterData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final createdAt = DateTime.parse(letterData['createdAt']);
        return AlertDialog(
          backgroundColor: letterData['isDeveloper'] == true
              ? Colors.blue[50]
              : null,
          title: Row(
            children: [
              Text(letterData['emotion'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                letterData['recipient'],
                style: TextStyle(
                  color: letterData['isDeveloper'] == true
                      ? Colors.blue[700]
                      : null,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (letterData['isDeveloper'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '개발자 편지',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  letterData['content'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  '작성일: ${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
