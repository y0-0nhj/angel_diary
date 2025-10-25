// 이메일/비밀번호 기반 인증과 세션 복원, 로그인 상태 캐싱을 담당하는 서비스입니다.
// - 1차 원천: Supabase 세션 (권위 있는 로그인 상태)
// - 2차 캐시: SharedPreferences ('is_logged_in', 'user_email')
// - 콜백: 로그인 성공 이벤트 브로드캐스트 (선택적)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';

  // 로그인 완료 콜백
  static VoidCallback? _onLoginSuccess;

  /// 이메일/비밀번호로 로그인합니다. 성공 시 Supabase 세션이 갱신됩니다.
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 이메일/비밀번호로 회원가입합니다.
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'angeldiary://auth-callback',
    );
  }

  /// 로그아웃합니다. Supabase 세션을 무효화합니다.
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }

  /// 현재 로그인한 사용자의 이메일 (세션 기준).
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  /// 현재 로그인한 사용자의 ID (세션 기준).
  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  /// 현재 세션이 존재하는지 여부.
  bool isLoggedIn() {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  /// 로그인 여부 비동기 확인.
  /// 우선 Supabase 세션을 확인하고, 없을 경우 SharedPreferences 캐시를 확인합니다.
  Future<bool> isLoggedInAsync() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      return true;
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// 로그인 상태와 이메일을 SharedPreferences에 캐시합니다.
  Future<void> saveLoginState(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
  }

  /// SharedPreferences의 로그인 캐시를 모두 제거합니다.
  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    // 게스트 데이터 플래그도 초기화
    await prefs.remove('hasGuestData');
  }

  /// 과거에 로그인 플래그가 저장되었는지 확인합니다.
  Future<bool> wasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// SharedPreferences에 저장된 사용자 이메일을 반환합니다.
  Future<String?> getSavedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// 세션 복원: Supabase가 저장소에서 세션을 복원했는지 확인하고 유효성 검증합니다.
  /// 실패 시 로컬 캐시를 정리합니다.
  Future<bool> restoreSession() async {
    try {
      // Supabase automatically restores session from storage
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Verify session is still valid
        final user = session.user;
        if (user != null) {
          print('세션 복원 성공: ${user.email}');
          return true;
        }
      }

      // If no valid session, clear saved state
      await clearLoginState();
      return false;
    } catch (e) {
      print('세션 복원 실패: $e');
      await clearLoginState();
      return false;
    }
  }

  // 로그인 성공 콜백 설정 (선택적)
  static void setOnLoginSuccess(VoidCallback? callback) {
    _onLoginSuccess = callback;
  }

  // 로그인 성공 콜백 호출
  static void triggerLoginSuccess() {
    _onLoginSuccess?.call();
  }

  // 로그인 성공 콜백 제거
  static void clearLoginSuccessCallback() {
    _onLoginSuccess = null;
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'angeldiary://auth-callback',
    );
  }

  /// 이메일 인증 재전송
  Future<void> sendEmailVerification(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }
}
