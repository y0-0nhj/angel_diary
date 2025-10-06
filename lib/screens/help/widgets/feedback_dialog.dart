import 'package:flutter/material.dart';
import '../../../main.dart' show bgColor;
import '../../../generated/l10n/app_localizations.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _currentStep = 0;
  String _category = '기능 제안';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 타이틀 가져오기
  String _getTitle() {
    switch (_currentStep) {
      case 0:
        return '문의 유형';
      case 1:
        return '내용 입력';
      case 2:
        return '이메일 주소 (선택 사항)';
      default:
        return '';
    }
  }

  // 컨텐츠 가져오기
  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStepContent();
      case 1:
        return _buildMessageStepContent();
      case 2:
        return _buildEmailStepContent();
      default:
        return const SizedBox();
    }
  }

  // 카테고리 단계 컨텐츠
  Widget _buildCategoryStepContent() {
    return Column(
      children: [
        ListTile(
          title: const Text('기능 제안'),
          subtitle: const Text('원하는 기능을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '기능 제안';
              _currentStep++;
            });
          },
        ),
        ListTile(
          title: const Text('버그 신고'),
          subtitle: const Text('불편한 점을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '버그 신고';
              _currentStep++;
            });
          },
        ),
        ListTile(
          title: const Text('궁금한 점'),
          subtitle: const Text('궁금한 점을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '기타 문의';
              _currentStep++;
            });
          },
        ),
      ],
    );
  }

  // 메시지 단계 컨텐츠
  Widget _buildMessageStepContent() {
    return Column(
      children: [
        TextField(
          controller: _messageController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '내용을 입력해주세요...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // 이메일 단계 컨텐츠
  Widget _buildEmailStepContent() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: '이메일 주소를 입력해주세요 (선택사항)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // 액션 버튼들
  List<Widget> _buildActions() {
    if (_currentStep == 0) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ];
    } else if (_currentStep == 2) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep--;
            });
          },
          child: Text(AppLocalizations.of(context)!.previous),
        ),
        TextButton(
          onPressed: _submitFeedback,
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep--;
            });
          },
          child: Text(AppLocalizations.of(context)!.previous),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep++;
            });
          },
          child: Text(AppLocalizations.of(context)!.next),
        ),
      ];
    }
  }

  void _submitFeedback() {
    // 피드백 제출 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.feedbackSubmitted)),
    );
    Navigator.pop(context, {
      'category': _category,
      // 문자열로 전달해 downstream에서 타입 오류가 나지 않도록 처리
      'title': _getTitle(),
      'message': _messageController.text.trim(),
      'email': _emailController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_getTitle()),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }
}
