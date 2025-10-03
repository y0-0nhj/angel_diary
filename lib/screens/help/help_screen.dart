import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

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
            onTap: () {
              // 고객 지원 페이지로 이동
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
