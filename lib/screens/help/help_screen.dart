import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import 'widgets/feedback_dialog.dart';
import '../../clients/discode_webhook.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

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

              final feedback = await FeedbackDialog.show(context);
              if (feedback == null) return;

              // 마지막 사용자로부터 받은 메시지를 디스코드로 전송
              // 1 타이틀
              // 문의 카테고리, 앱 이름, 앱 버전
              final packageInfo = await _getPackageInfo();
              final title =
                  '${feedback['category']} :: ${packageInfo.appName} ${packageInfo.version}';
              // 2. 메시지
              // 문의 내용 + 기기 정보
              final deviceInfo =
                  '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
              String message = '💬 ${feedback['message']}';
              message +=
                  '\n\n📧 ${feedback['email']!.isNotEmpty ? feedback['email'] : '제공하지 않음'}';
              message += '\n\n💻$deviceInfo';

              // 3. 우선순위
              // 문의 카테고리에 따라 스위치 문으로 우선순위 지정
              // Priority 매핑: 카테고리에 따라 우선순위 지정
              final priority = switch (feedback['category']) {
                '기능 제안' => Priority.medium,
                '버그 신고' => Priority.high,
                _ => Priority.low,
              };

              await DiscodeWebhookClient().sendMessage(
                title,
                message,
                priority,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보 처리방침'),
            subtitle: const Text('앱의 개인정보 처리방침 보기'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('이용 약관'),
            subtitle: const Text('앱의 이용 약관 보기'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
