import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../main.dart' show primaryColor;
import '../../models/angel_data.dart';
import '../../managers/angel_data_manager.dart' as adm;
import '../../home.dart';
import '../../services/auth/kakao_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile.dart';

class IntroSignupScreen extends StatelessWidget {
  final AngelData angelData;

  const IntroSignupScreen({super.key, required this.angelData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F5EF), // bgColor
              Color(0xFFF0EDE5), // 연한 베이지
              Color(0xFFE8E5DD), // 더 연한 베이지
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 140),

                // 로고/아이콘 영역
                _buildLogoSection(),

                const SizedBox(height: 100),

                // 로그인 버튼들
                _buildLoginButtons(context, l10n),

                const SizedBox(height: 100),

                // 푸터
                _buildFooter(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // 천사 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.8),
                primaryColor.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
        ),

        const SizedBox(height: 24),

        // 앱 이름
        Text(
          '천사일기',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: 'Cafe24Oneprettynight',
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // 부제목
        Text(
          '당신의 소중한 순간을 기록하세요',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Cafe24Oneprettynight',
            letterSpacing: 0.5,
          ),
        ),
        Text(
          '천사와 함께하는 특별한 일기를 시작해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Cafe24Oneprettynight',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // 카카오 로그인 버튼
        _buildModernLoginButton(
          context: context,
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.black,
          backgroundColor: const Color(0xFFFEE500),
          text: l10n.startWithKakao,
          onPressed: () => _handleKakaoLogin(context),
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        // 약관 동의
        Text(
          '계속 진행하시면 서비스 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildModernLoginButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: isPrimary ? null : backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),

                const SizedBox(width: 16),

                // 텍스트
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                    fontFamily: 'Cafe24Oneprettynight',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 로그인/가입 완료 후 처리
  Future<void> _handleAuthSuccess(BuildContext context) async {
    // 현재 라우트 디버그 로그
    debugPrint('=== 인증 성공 후 라우트 이동 ===');
    debugPrint('현재 라우트: ${ModalRoute.of(context)?.settings.name}');

    try {
      // 디버그: 전달된 천사 데이터 확인
      debugPrint('=== 전달된 천사 데이터 ===');
      debugPrint('이름: ${angelData.name}');
      debugPrint('특징: ${angelData.feature}');
      debugPrint('동물 타입: ${angelData.animalType}');
      debugPrint('얼굴 타입: ${angelData.faceType}');
      debugPrint('얼굴 색상: ${angelData.faceColor}');
      debugPrint('꼬리 인덱스: ${angelData.tailIndex}');
      debugPrint('========================');

      // 천사 데이터를 SharedPreferences에 저장
      await adm.AngelDataManager.setCurrentAngel(angelData);

      // Supabase user_profiles 테이블에 천사 데이터 저장
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userProfileService = UserProfileService();

        // 기존 사용자 프로필 조회
        final existingProfile = await userProfileService.getUserProfileById(
          user.id,
        );

        if (existingProfile != null) {
          // 기존 프로필이 있으면 천사 데이터만 업데이트
          await userProfileService.updateAngelData(user.id, angelData.toJson());
          debugPrint('기존 사용자 프로필에 천사 데이터 업데이트 완료');
        } else {
          // 새 사용자 프로필 생성
          final newProfile = UserProfile(
            id: user.id,
            email: user.email ?? '',
            nickname: '익명의 천사',
            createdAt: DateTime.now(),
            lastActiveAt: DateTime.now(),
            pushNotificationEnabled: true,
            languagePreference: 'ko',
            exp: 0,
            level: 1,
            acorns: 0,
            isPremiumUser: false,
            angelData: angelData.toJson(),
          );

          await userProfileService.upsertUserProfile(newProfile);
          debugPrint('새 사용자 프로필 생성 및 천사 데이터 저장 완료');
        }
      }

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
    } catch (e) {
      debugPrint('천사 데이터 저장 중 오류 발생: $e');

      // 에러가 발생해도 SharedPreferences에는 저장되었으므로 계속 진행
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('천사 데이터 저장 중 일부 오류가 발생했습니다: $e'),
          backgroundColor: Colors.orange,
        ),
      );

      // 홈 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
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
}
