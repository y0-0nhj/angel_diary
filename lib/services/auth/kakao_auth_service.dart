import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_common.dart' as kakao;
import 'auth_service.dart';

class KakaoAuthService {
  static final KakaoAuthService _instance = KakaoAuthService._internal();
  factory KakaoAuthService() => _instance;
  KakaoAuthService._internal();

  final supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  /// 카카오 SDK를 사용하여 네이티브 로그인을 수행하고 Supabase에 인증합니다.
  Future<void> signInWithKakao() async {
    kakao.OAuthToken? token;

    // 카카오톡으로 로그인 시도
    try {
      token = await kakao.UserApi.instance.loginWithKakaoTalk();
      print('카카오톡으로 로그인 성공');
    } catch (error) {
      print('카카오톡으로 로그인 실패: $error');

      // 사용자가 로그인을 취소한 경우, 에러 처리를 하지 않고 함수를 종료합니다.
      if (error is PlatformException && error.code == 'CANCELED') {
        return;
      }

      // 카카오톡이 설치되지 않았거나, 기타 오류 발생 시 카카오계정으로 로그인 시도
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패: $error');
        return; // 로그인 최종 실패
      }
    }

    if (token == null) {
      print('카카오 토큰 발급 실패');
      return;
    }

    // 토큰 정보 디버깅
    print('=== 카카오 토큰 정보 ===');
    print('Access Token: ${token.accessToken}');
    print('ID Token: ${token.idToken}');
    print('Refresh Token: ${token.refreshToken}');
    print('Scopes: ${token.scopes}');
    print('========================');

    // 카카오 사용자 정보 가져오기
    await _getKakaoUserInfo();

    if (token.idToken == null) {
      print('ID 토큰이 없습니다. 카카오 개발자 콘솔에서 OpenID Connect 활성화가 필요합니다.');
      return;
    }

    try {
      print('Supabase에 ID 토큰으로 로그인 시도');
      print('Provider: ${OAuthProvider.kakao}');
      print('ID Token: ${token.idToken!.substring(0, 50)}...');

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
        accessToken: token.accessToken,
      );
      print('Supabase 로그인 성공');

      // 로그인 상태 저장
      final user = supabase.auth.currentUser;
      if (user?.email != null) {
        await _authService.saveLoginState(user!.email!);
        print('로그인 상태 저장 완료: ${user.email}');
      }
    } on AuthException catch (e) {
      print('Supabase 로그인 오류: ${e.message}');
      print('오류 코드: ${e.statusCode}');
      rethrow;
    } catch (e) {
      print('알 수 없는 오류 발생: $e');
      rethrow;
    }
  }

  /// 카카오 사용자 정보를 가져옵니다.
  Future<void> _getKakaoUserInfo() async {
    try {
      kakao.User user = await kakao.UserApi.instance.me();
      print('=== 카카오 사용자 정보 ===');
      print('ID: ${user.id}');
      print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('프로필 이미지: ${user.kakaoAccount?.profile?.profileImageUrl}');
      print('이메일: ${user.kakaoAccount?.email}');
      print('이메일 인증 여부: ${user.kakaoAccount?.emailNeedsAgreement}');
      print('이메일 유효 여부: ${user.kakaoAccount?.isEmailValid}');
      print('이메일 인증 여부: ${user.kakaoAccount?.isEmailVerified}');
      print('성별: ${user.kakaoAccount?.gender}');
      print('생일: ${user.kakaoAccount?.birthday}');
      print('연령대: ${user.kakaoAccount?.ageRange}');
      print('전화번호: ${user.kakaoAccount?.phoneNumber}');
      print('계정 생성일: ${user.connectedAt}');
      print('동의 항목: ${user.kakaoAccount?.profileNicknameNeedsAgreement}');
      print('========================');
    } catch (error) {
      print('카카오 사용자 정보 가져오기 실패: $error');
    }
  }

  /// 현재 카카오 사용자 정보를 가져옵니다.
  Future<kakao.User?> getCurrentKakaoUser() async {
    try {
      // 토큰 존재 여부 확인
      if (await kakao.AuthApi.instance.hasToken()) {
        try {
          // 토큰 유효성 확인
          await kakao.UserApi.instance.accessTokenInfo();
          // 사용자 정보 가져오기
          kakao.User user = await kakao.UserApi.instance.me();
          return user;
        } catch (error) {
          if (error is kakao.KakaoException && error.isInvalidTokenError()) {
            print('토큰이 만료되었습니다: $error');
          } else {
            print('토큰 정보 조회 실패: $error');
          }
          return null;
        }
      } else {
        print('발급된 토큰이 없습니다.');
        return null;
      }
    } catch (error) {
      print('사용자 정보 가져오기 실패: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      // 카카오 SDK 로그아웃도 함께 호출하여 세션을 완전히 정리합니다.
      await kakao.UserApi.instance.logout();
      // 로그인 상태 정리
      await _authService.clearLoginState();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }
}
