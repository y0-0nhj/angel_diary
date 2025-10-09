import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../main.dart' show bgColor, primaryColor;
import '../../language_manager.dart';
import '../../models/angel_data.dart';
import '../../managers/angel_data_manager.dart' as adm;
import '../../home.dart';
import '../../services/auth/kakao_auth_service.dart';

class IntroSignupScreen extends StatelessWidget {
  final AngelData angelData;

  const IntroSignupScreen({super.key, required this.angelData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 제목
              Text(
                l10n.signUp,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                      ? 'Cafe24Oneprettynight'
                      : null,
                ),
              ),

              const SizedBox(height: 60),

              // 소셜 로그인 버튼들
              _buildSocialLoginButton(
                context: context,
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.black,
                backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
                text: l10n.startWithKakao,
                onPressed: () => _handleKakaoLogin(context),
              ),

              const SizedBox(height: 16),

              // _buildSocialLoginButton(
              //   context: context,
              //   icon: Icons.circle,
              //   iconColor: Colors.white,
              //   backgroundColor: const Color(0xFF03C75A), // 네이버 초록색
              //   text: l10n.startWithNaver,
              //   onPressed: () => _handleNaverLogin(context),
              // ),
              const SizedBox(height: 16),

              // _buildSocialLoginButton(
              //   context: context,
              //   icon: Icons.circle,
              //   iconColor: Colors.grey[600]!,
              //   backgroundColor: Colors.white,
              //   text: l10n.startWithGoogle,
              //   onPressed: () => _handleGoogleLogin(context),
              //   hasBorder: true,
              // ),
              const SizedBox(height: 40),

              // 구분선
              Text(
                l10n.or,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                      ? 'Cafe24Oneprettynight'
                      : null,
                ),
              ),

              const SizedBox(height: 40),

              // 이메일 가입 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _handleEmailSignup(context),
                  child: Text(
                    l10n.signUpWithEmail,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily:
                          LanguageManager.currentLocale.languageCode == 'ko'
                          ? 'Cafe24Oneprettynight'
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 기존 계정 링크
              TextButton(
                onPressed: () => _handleExistingAccount(context),
                child: Text(
                  l10n.alreadyHaveAccount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[600],
                    decoration: TextDecoration.underline,
                    fontFamily:
                        LanguageManager.currentLocale.languageCode == 'ko'
                        ? 'Cafe24Oneprettynight'
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String text,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: iconColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? BorderSide(color: Colors.grey[300]!, width: 1)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: backgroundColor),
            ),

            const SizedBox(width: 12),

            // 텍스트
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: iconColor,
                fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                    ? 'Cafe24Oneprettynight'
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인/가입 완료 후 처리
  Future<void> _handleAuthSuccess(BuildContext context) async {
    // 현재 라우트 디버그 로그
    debugPrint('=== 인증 성공 후 라우트 이동 ===');
    debugPrint('현재 라우트: ${ModalRoute.of(context)?.settings.name}');

    // 천사 데이터를 SharedPreferences에 저장
    await adm.AngelDataManager.setCurrentAngel(angelData);

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.angelSaved)),
    );

    // 모든 라우트 스택을 정리하고 홈 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false, // 모든 이전 라우트 제거
    );

    debugPrint('홈 화면으로 이동 완료');
  }

  // 카카오 로그인 처리
  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 카카오 로그인 실행
      await KakaoAuthService().signInWithKakao();

      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 성공 처리
      if (context.mounted) {
        _handleAuthSuccess(context);
      }
    } catch (error) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카카오 로그인 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 네이버 로그인 처리
  void _handleNaverLogin(BuildContext context) {
    // TODO: 네이버 로그인 구현
    // 임시로 성공 처리
    _handleAuthSuccess(context);
  }

  // 구글 로그인 처리
  void _handleGoogleLogin(BuildContext context) {
    // TODO: 구글 로그인 구현
    // 임시로 성공 처리
    _handleAuthSuccess(context);
  }

  // 이메일 가입 처리
  void _handleEmailSignup(BuildContext context) {
    // TODO: 이메일 가입 화면으로 이동
    // 임시로 성공 처리
    _handleAuthSuccess(context);
  }

  // 기존 계정 처리
  void _handleExistingAccount(BuildContext context) {
    // TODO: 로그인 화면으로 이동
    // 임시로 성공 처리
    _handleAuthSuccess(context);
  }
}
