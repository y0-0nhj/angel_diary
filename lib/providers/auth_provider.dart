import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';

/// 인증 상태를 관리하는 Provider
///
/// 로그인, 로그아웃, 세션 복원을 담당하고
/// UI에 인증 상태 변화를 알려줍니다.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  bool _isLoading = false;
  String? _error;

  /// 로그인 상태
  bool get isLoggedIn => _isLoggedIn;

  /// 사용자 이메일
  String? get userEmail => _userEmail;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get error => _error;

  /// 이메일/비밀번호로 로그인
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authService = AuthService();
      final response = await authService.signInWithEmailPassword(
        email,
        password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        _userEmail = email;
        await authService.saveLoginState(email);
        print('로그인 성공: $email');
        return true;
      } else {
        _setError('로그인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('로그인 중 오류가 발생했습니다: $e');
      print('로그인 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 이메일/비밀번호로 회원가입
  Future<bool> signUpWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authService = AuthService();
      final response = await authService.signUpWithEmailPassword(
        email,
        password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        _userEmail = email;
        await authService.saveLoginState(email);
        print('회원가입 성공: $email');
        return true;
      } else {
        _setError('회원가입에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('회원가입 중 오류가 발생했습니다: $e');
      print('회원가입 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      final authService = AuthService();
      await authService.signOut();
      await authService.clearLoginState();

      _isLoggedIn = false;
      _userEmail = null;
      print('로그아웃 완료');
    } catch (e) {
      _setError('로그아웃 중 오류가 발생했습니다: $e');
      print('로그아웃 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 세션 복원
  Future<bool> restoreSession() async {
    _setLoading(true);
    _clearError();

    try {
      final authService = AuthService();
      final isRestored = await authService.restoreSession();

      if (isRestored) {
        _isLoggedIn = true;
        _userEmail = authService.getCurrentUserEmail();
        print('세션 복원 성공: $_userEmail');
      } else {
        _isLoggedIn = false;
        _userEmail = null;
        print('세션 복원 실패');
      }

      return isRestored;
    } catch (e) {
      _setError('세션 복원 중 오류가 발생했습니다: $e');
      print('세션 복원 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final authService = AuthService();
      await authService.resetPassword(email);
      print('비밀번호 재설정 이메일 전송: $email');
      return true;
    } catch (e) {
      _setError('비밀번호 재설정 중 오류가 발생했습니다: $e');
      print('비밀번호 재설정 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// 에러 초기화
  void _clearError() {
    _error = null;
  }
}
