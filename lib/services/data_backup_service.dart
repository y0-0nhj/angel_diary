import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daily.dart';
import 'user_profile_service.dart';
import '../managers/angel_data_manager.dart';
import '../models/angel_data.dart';

class DataBackupService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DailyRepository _dailyRepository = DailyRepository();
  final UserProfileService _userProfileService = UserProfileService();

  /// SharedPreferences의 모든 데이터를 Supabase로 백업합니다
  Future<Map<String, dynamic>> backupAllData() async {
    final results = <String, dynamic>{
      'success': true,
      'backedUpItems': <String>[],
      'errors': <String>[],
    };

    try {
      // 1. 사용자 프로필 백업 (이미 로그인 시 저장되지만 최신 정보로 업데이트)
      await _backupUserProfile(results);

      // 2. 천사 데이터 백업
      await _backupAngelData(results);

      // 3. 일기 데이터 백업
      await _backupDailyData(results);

      print('=== 데이터 백업 완료 ===');
      print('백업된 항목: ${results['backedUpItems']}');
      if (results['errors'].isNotEmpty) {
        print('오류: ${results['errors']}');
      }
    } catch (e) {
      results['success'] = false;
      results['errors'].add('전체 백업 실패: $e');
      print('데이터 백업 실패: $e');
    }

    return results;
  }

  /// 사용자 프로필을 백업합니다
  Future<void> _backupUserProfile(Map<String, dynamic> results) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        results['errors'].add('로그인된 사용자가 없습니다');
        return;
      }

      // 현재 사용자 프로필 조회
      final currentProfile = await _userProfileService.getCurrentUserProfile();
      if (currentProfile != null) {
        // 마지막 활동 시간 업데이트
        await _userProfileService.updateLastActiveAt(user.id);
        results['backedUpItems'].add('사용자 프로필 (마지막 활동 시간)');
      }
    } catch (e) {
      results['errors'].add('사용자 프로필 백업 실패: $e');
    }
  }

  /// 천사 데이터를 백업합니다
  Future<void> _backupAngelData(Map<String, dynamic> results) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        results['errors'].add('로그인된 사용자가 없습니다');
        return;
      }

      // SharedPreferences에서 천사 데이터 로드 시도
      AngelData? angelData = AngelDataManager.currentAngel;
      if (angelData == null) {
        // 메모리에 없으면 SharedPreferences에서 로드 시도
        angelData = await AngelDataManager.loadAngelFromStorage();
      }

      if (angelData != null) {
        // 천사 데이터를 JSON으로 변환
        final angelDataJson = angelData.toJson();

        // user_profiles 테이블의 angel_data 필드에 저장
        await _userProfileService.updateAngelData(user.id, angelDataJson);
        results['backedUpItems'].add('천사 데이터');
        print('천사 데이터 백업 성공: ${angelData.name}');
      } else {
        results['errors'].add('백업할 천사 데이터가 없습니다');
        print('천사 데이터가 SharedPreferences에도 없습니다');
      }
    } catch (e) {
      results['errors'].add('천사 데이터 백업 실패: $e');
      print('천사 데이터 백업 중 오류: $e');
    }
  }

  /// 일기 데이터를 백업합니다
  Future<void> _backupDailyData(Map<String, dynamic> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // SharedPreferences에서 모든 키 가져오기
      final keys = prefs.getKeys();
      int backedUpCount = 0;

      for (final key in keys) {
        // 날짜 형식의 키만 처리 (예: "2024-01-15")
        if (_isDateKey(key)) {
          try {
            final dateStr = key;
            final date = DateTime.parse(dateStr);

            // 해당 날짜의 데이터 가져오기
            final goalData = await _getGoalDataForDate(prefs, dateStr);
            final gratitudeData = await _getGratitudeDataForDate(
              prefs,
              dateStr,
            );
            final diaryData = await _getDiaryDataForDate(prefs, dateStr);

            // Supabase에 저장
            await _dailyRepository.createOrUpsert(
              date: date,
              goal: goalData,
              gratitude: gratitudeData,
              diary: diaryData,
            );

            backedUpCount++;
          } catch (e) {
            results['errors'].add('날짜 $key 백업 실패: $e');
          }
        }
      }

      if (backedUpCount > 0) {
        results['backedUpItems'].add('일기 데이터 ($backedUpCount개 날짜)');
      }
    } catch (e) {
      results['errors'].add('일기 데이터 백업 실패: $e');
    }
  }

  /// 날짜 형식의 키인지 확인합니다
  bool _isDateKey(String key) {
    // YYYY-MM-DD 형식인지 확인
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(key)) return false;

    try {
      DateTime.parse(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 특정 날짜의 목표 데이터를 가져옵니다
  Future<Map<String, dynamic>?> _getGoalDataForDate(
    SharedPreferences prefs,
    String dateStr,
  ) async {
    try {
      final goalKey = '${dateStr}_goal';
      final goalJson = prefs.getString(goalKey);

      if (goalJson != null && goalJson.isNotEmpty) {
        // JSON 문자열을 Map으로 파싱
        return {
          'items': goalJson
              .split(',')
              .map(
                (item) => {
                  'text': item.trim(),
                  'completed': false, // 기본값
                },
              )
              .toList(),
          'backupDate': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      print('목표 데이터 파싱 실패 ($dateStr): $e');
      return null;
    }
  }

  /// 특정 날짜의 감사 데이터를 가져옵니다
  Future<Map<String, dynamic>?> _getGratitudeDataForDate(
    SharedPreferences prefs,
    String dateStr,
  ) async {
    try {
      final gratitudeKey = '${dateStr}_gratitude';
      final gratitudeJson = prefs.getString(gratitudeKey);

      if (gratitudeJson != null && gratitudeJson.isNotEmpty) {
        // JSON 문자열을 Map으로 파싱
        return {
          'items': gratitudeJson
              .split(',')
              .map(
                (item) => {
                  'text': item.trim(),
                  'completed': false, // 기본값
                },
              )
              .toList(),
          'backupDate': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      print('감사 데이터 파싱 실패 ($dateStr): $e');
      return null;
    }
  }

  /// 특정 날짜의 일기 데이터를 가져옵니다
  Future<String?> _getDiaryDataForDate(
    SharedPreferences prefs,
    String dateStr,
  ) async {
    try {
      final diaryKey = '${dateStr}_diary';
      return prefs.getString(diaryKey);
    } catch (e) {
      print('일기 데이터 가져오기 실패 ($dateStr): $e');
      return null;
    }
  }

  /// 백업 상태를 확인합니다
  Future<Map<String, dynamic>> getBackupStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'isLoggedIn': false, 'message': '로그인이 필요합니다'};
      }

      // 사용자 프로필 확인
      final profile = await _userProfileService.getCurrentUserProfile();
      if (profile == null) {
        return {
          'isLoggedIn': true,
          'hasProfile': false,
          'message': '사용자 프로필이 없습니다',
        };
      }

      // 최근 백업된 일기 데이터 확인
      final recentDailies = await _dailyRepository.listRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      );

      return {
        'isLoggedIn': true,
        'hasProfile': true,
        'recentBackupCount': recentDailies.length,
        'lastBackupDate': profile.updatedAt?.toIso8601String(),
        'message': '백업 가능한 상태입니다',
      };
    } catch (e) {
      return {'isLoggedIn': false, 'message': '백업 상태 확인 실패: $e'};
    }
  }
}
