import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 딥링크 처리를 담당하는 서비스
///
/// 이메일 인증, 비밀번호 재설정 등의 딥링크를 처리합니다.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // 이메일 인증 완료 콜백
  static void Function()? _onEmailVerified;

  /// 딥링크 리스너 초기화
  void initialize() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        print('딥링크 에러: $err');
      },
    );
  }

  /// 딥링크 처리
  Future<void> _handleDeepLink(Uri uri) async {
    print('딥링크 수신: $uri');

    try {
      // Supabase 인증 관련 딥링크 처리
      if (uri.scheme == 'angeldiary' || uri.scheme == 'https') {
        await _handleAuthDeepLink(uri);
      }
    } catch (e) {
      print('딥링크 처리 에러: $e');
    }
  }

  /// 인증 관련 딥링크 처리
  Future<void> _handleAuthDeepLink(Uri uri) async {
    final supabase = Supabase.instance.client;

    // URL에서 토큰 추출
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    final type = uri.queryParameters['type'];

    if (accessToken != null && refreshToken != null) {
      // 세션 설정
      await supabase.auth.setSession(accessToken);

      print('인증 토큰 설정 완료');

      // 이메일 인증 완료 처리
      if (type == 'signup' || type == 'email') {
        await _handleEmailVerification();
      }
    }
  }

  /// 이메일 인증 완료 처리
  Future<void> _handleEmailVerification() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        print('이메일 인증 완료: ${user.email}');

        // 콜백 호출 (대기 화면에 알림)
        _onEmailVerified?.call();

        // 사용자 정보 업데이트 (필요시)
        // await supabase.from('profiles').update({
        //   'email_verified': true,
        // }).eq('id', user.id);
      }
    } catch (e) {
      print('이메일 인증 처리 에러: $e');
    }
  }

  /// 이메일 인증 완료 콜백 설정
  static void setOnEmailVerified(void Function() callback) {
    _onEmailVerified = callback;
  }

  /// 이메일 인증 완료 콜백 제거
  static void clearOnEmailVerified() {
    _onEmailVerified = null;
  }

  /// 딥링크 리스너 해제
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// 앱이 종료된 상태에서 딥링크로 실행된 경우 처리
  Future<void> handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('초기 딥링크 처리 에러: $e');
    }
  }
}
