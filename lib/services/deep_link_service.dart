import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/angel_data.dart';
import '../models/user_profile.dart';
import '../managers/angel_data_manager.dart' as adm;
import 'auth/auth_service.dart';
import 'user_profile_service.dart';

/// Deep Link 처리를 위한 서비스
/// 블로그 참고: https://ownerdev88.tistory.com/440
class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static bool _isInitialized = false;

  /// Deep Link 서비스 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 앱이 종료된 상태에서 Deep Link로 실행된 경우
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        print('초기 Deep Link: $initialLink');
        await _handleDeepLink(initialLink);
      }

      // 앱이 실행 중일 때 Deep Link 수신
      _appLinks.uriLinkStream.listen(
        (Uri uri) async {
          print('Deep Link 수신: $uri');
          await _handleDeepLink(uri);
        },
        onError: (err) {
          print('Deep Link 오류: $err');
        },
      );

      _isInitialized = true;
      print('Deep Link 서비스 초기화 완료');
    } catch (e) {
      print('Deep Link 서비스 초기화 실패: $e');
    }
  }

  /// Deep Link 처리
  static Future<void> _handleDeepLink(Uri uri) async {
    try {
      print('Deep Link 처리 시작: $uri');

      // scheme 확인
      if (uri.scheme != 'angeldiary') {
        print('지원하지 않는 scheme: ${uri.scheme}');
        return;
      }

      // host 확인
      if (uri.host != 'redirect') {
        print('지원하지 않는 host: ${uri.host}');
        return;
      }

      // path 확인
      if (uri.path != '/main') {
        print('지원하지 않는 path: ${uri.path}');
        return;
      }

      // 쿼리 파라미터 확인
      final signup = uri.queryParameters['signup'];
      final callback = uri.queryParameters['callback'];

      print('Deep Link 파라미터 - signup: $signup, callback: $callback');

      if (callback == 'true') {
        // 이메일 인증 완료 처리
        await _handleEmailVerification(signup == 'true');
      }
    } catch (e) {
      print('Deep Link 처리 오류: $e');
    }
  }

  /// 이메일 인증 완료 처리
  static Future<void> _handleEmailVerification(bool isSignup) async {
    try {
      print('이메일 인증 완료 처리 시작 - 회원가입: $isSignup');

      // Supabase 세션 확인
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('세션이 없습니다. 다시 로그인해주세요.');
        return;
      }

      final user = session.user;
      if (user == null) {
        print('사용자 정보가 없습니다.');
        return;
      }

      print('인증된 사용자: ${user.email}');

      if (isSignup) {
        // 회원가입 완료 처리
        await _handleSignupCompletion(user);
      } else {
        // 로그인 완료 처리
        await _handleLoginCompletion(user);
      }
    } catch (e) {
      print('이메일 인증 완료 처리 오류: $e');
    }
  }

  /// 회원가입 완료 처리
  static Future<void> _handleSignupCompletion(User user) async {
    try {
      print('회원가입 완료 처리 시작');

      // 임시 저장된 천사 데이터 확인
      final prefs = await SharedPreferences.getInstance();
      final tempAngelData = prefs.getString('temp_angel_data');

      if (tempAngelData != null) {
        print('임시 천사 데이터 발견, 서버로 이전');

        // 천사 데이터를 서버에 저장
        final angelData = AngelData.fromJson(jsonDecode(tempAngelData));
        final userProfileService = UserProfileService();

        // 사용자 프로필 업데이트 (천사 데이터 포함)
        final userProfile = await userProfileService.getUserProfileById(
          user.id,
        );
        if (userProfile != null) {
          final updatedProfile = UserProfile(
            id: userProfile.id,
            email: userProfile.email,
            nickname: userProfile.nickname,
            createdAt: userProfile.createdAt,
            lastActiveAt: userProfile.lastActiveAt,
            pushNotificationEnabled: userProfile.pushNotificationEnabled,
            languagePreference: userProfile.languagePreference,
            exp: userProfile.exp,
            level: userProfile.level,
            acorns: userProfile.acorns,
            isPremiumUser: userProfile.isPremiumUser,
            angelData: angelData.toJson(),
            updatedAt: DateTime.now(),
          );
          await userProfileService.upsertUserProfile(updatedProfile);

          // AngelDataManager에 설정
          await adm.AngelDataManager.setCurrentAngel(angelData);

          // 임시 데이터 삭제
          await prefs.remove('temp_angel_data');

          print('천사 데이터 서버 이전 완료');
        }
      }

      // 로그인 상태 저장
      final authService = AuthService();
      await authService.saveLoginState(user.email ?? '');

      print('회원가입 완료 처리 성공');
    } catch (e) {
      print('회원가입 완료 처리 오류: $e');
    }
  }

  /// 로그인 완료 처리
  static Future<void> _handleLoginCompletion(User user) async {
    try {
      print('로그인 완료 처리 시작');

      // 사용자 프로필에서 천사 데이터 로드
      final userProfileService = UserProfileService();
      final userProfile = await userProfileService.getUserProfileById(user.id);

      if (userProfile != null && userProfile.angelData != null) {
        final angelData = AngelData.fromJson(userProfile.angelData!);
        await adm.AngelDataManager.setCurrentAngel(angelData);
        print('사용자 천사 데이터 로드 완료');
      }

      // 로그인 상태 저장
      final authService = AuthService();
      await authService.saveLoginState(user.email ?? '');

      print('로그인 완료 처리 성공');
    } catch (e) {
      print('로그인 완료 처리 오류: $e');
    }
  }

  /// Deep Link URL 생성 (테스트용)
  static String generateDeepLinkUrl({
    required String host,
    required String path,
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri(
      scheme: 'angeldiary',
      host: host,
      path: path,
      queryParameters: queryParameters,
    );
    return uri.toString();
  }
}
