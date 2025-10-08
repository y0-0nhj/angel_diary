import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  
  // 로그인 완료 콜백
  static VoidCallback? _onLoginSuccess;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // sign out
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Check if user is currently logged in
  bool isLoggedIn() {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // Save login state to SharedPreferences
  Future<void> saveLoginState(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
  }

  // Clear login state from SharedPreferences
  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if user was previously logged in
  Future<bool> wasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get saved user email
  Future<String?> getSavedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Initialize session restoration
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

  // 로그인 성공 콜백 설정
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
}
