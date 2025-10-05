import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import 'widgets/feedback_dialog.dart';
import '../../clients/discode_webhook.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.help),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appInfo),
            subtitle: const Text('1.0.0'),
            onTap: () {
              // 앱 정보 상세 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('서비스 소개'),
            subtitle: const Text('앱 사용법 및 기능 안내'),
            onTap: () {
              // 서비스 소개 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('고객 지원'),
            subtitle: const Text('문의 사항이나 피드백 보내기'),
            onTap: () async {
              //TODO: 고객문의/제안 페이지로 이동
              //1. 문의 유형 선택(기능 제안, 버그 신고, 기타 문제)
              //2. 문의 내용 입력
              //3. 이메일 주소 입력(선택사항)
              var feedback = await FeedbackDialog.show(context);
              print(feedback);

              // 4. 제출 버튼 클릭 시 마지막 사용자로부터 받은 메시지를 디스코드로 전송
              await DiscodeWebhook().sendMessage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보 처리방침'),
            subtitle: const Text('앱의 개인정보 처리방침 보기'),
            onTap: () {
              // 개인정보 처리방침 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('이용 약관'),
            subtitle: const Text('앱의 이용 약관 보기'),
            onTap: () {
              // 이용 약관 페이지로 이동
            },
          ),
        ],
      ),
    );
  }
}
