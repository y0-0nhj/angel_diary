import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'angel_provider.dart';
import 'auth_provider.dart';

/// 앱 전체 상태를 관리하는 Provider
///
/// 앱 초기화, 사용자 상태 확인, 화면 분기 로직을 담당합니다.
class AppProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _hasAngel = false;
  bool _isLoggedIn = false;
  bool _hasGuestData = false;
  String? _error;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 천사 데이터 존재 여부
  bool get hasAngel => _hasAngel;

  /// 로그인 상태
  bool get isLoggedIn => _isLoggedIn;

  /// 게스트 데이터 존재 여부
  bool get hasGuestData => _hasGuestData;

  /// 에러 메시지
  String? get error => _error;

  /// 앱 초기화 및 사용자 상태 확인
  Future<void> initializeApp(
    AngelProvider angelProvider,
    AuthProvider authProvider,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      print('=== 앱 초기화 시작 ===');

      // 1. SharedPreferences에서 사용자 상태 정보 로드
      final prefs = await SharedPreferences.getInstance();
      final hasVisitedBefore = prefs.getBool('hasVisitedBefore') ?? false;
      final hasGuestData = prefs.getBool('hasGuestData') ?? false;

      print('첫 방문 여부: ${!hasVisitedBefore}');
      print('게스트 데이터 여부: $hasGuestData');

      // 2. 첫 방문 여부 확인
      if (!hasVisitedBefore) {
        await prefs.setBool('hasVisitedBefore', true);
        print('✅ 첫 방문 → 온보딩 화면');

        _hasAngel = false;
        _isLoggedIn = false;
        _hasGuestData = false;
        _setLoading(false);
        return;
      }

      // 3. 재방문 사용자 - 로그인 상태 확인
      final isLoggedIn = authProvider.isLoggedIn;
      print('재방문 & 로그인 상태: $isLoggedIn');

      // 4. 로그아웃 상태 처리
      if (!isLoggedIn) {
        if (hasGuestData) {
          // 게스트 데이터가 있는 경우: 천사 데이터도 확인 필요
          await angelProvider.loadAngel();
          print('✅ 재방문 & 로그아웃 & 게스트 데이터 있음 → 천사 데이터 확인');
          print('게스트 모드 천사 등록 여부: ${angelProvider.hasAngel}');

          _hasAngel = angelProvider.hasAngel;
          _isLoggedIn = false;
          _hasGuestData = true;
          _setLoading(false);
          return;
        } else {
          // 게스트 데이터가 없는 경우: 온보딩 화면으로 이동
          print('✅ 재방문 & 로그아웃 & 게스트 데이터 없음 → 온보딩 화면');

          _hasAngel = false;
          _isLoggedIn = false;
          _hasGuestData = false;
          _setLoading(false);
          return;
        }
      }

      // 5. 로그인 상태 처리
      await angelProvider.loadAngel();
      print('✅ 재방문 & 로그인 → 천사 데이터 확인');
      print('천사 등록 여부: ${angelProvider.hasAngel}');

      _hasAngel = angelProvider.hasAngel;
      _isLoggedIn = isLoggedIn;
      _hasGuestData = false;
      _setLoading(false);
    } catch (e) {
      _setError('앱 초기화 중 오류가 발생했습니다: $e');
      print('❌ 앱 초기화 실패: $e');

      // 안전한 기본 상태로 설정
      _hasAngel = false;
      _isLoggedIn = false;
      _hasGuestData = false;
      _setLoading(false);
    }
  }

  /// 천사 생성 완료 후 상태 업데이트
  void onAngelCreated() {
    _hasAngel = true;
    notifyListeners();
  }

  /// 로그인 완료 후 상태 업데이트
  void onLoginSuccess() {
    _isLoggedIn = true;
    _hasGuestData = false;
    notifyListeners();
  }

  /// 로그아웃 완료 후 상태 업데이트
  void onLogoutSuccess() {
    _isLoggedIn = false;
    notifyListeners();
  }

  /// 게스트 데이터 설정
  Future<void> setGuestData(bool hasData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasGuestData', hasData);
    _hasGuestData = hasData;
    notifyListeners();
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
