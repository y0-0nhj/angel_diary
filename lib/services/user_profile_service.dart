import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 사용자 프로필을 생성하거나 업데이트합니다 (upsert)
  Future<UserProfile> upsertUserProfile(UserProfile userProfile) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .upsert(userProfile.toMap())
          .select()
          .single();

      print('사용자 프로필 저장 성공: ${userProfile.email}');
      return UserProfile.fromMap(response);
    } catch (e) {
      print('사용자 프로필 저장 실패: $e');
      rethrow;
    }
  }

  /// ID로 사용자 프로필을 조회합니다
  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromMap(response);
    } catch (e) {
      print('사용자 프로필 조회 실패: $e');
      return null;
    }
  }

  /// 이메일로 사용자 프로필을 조회합니다
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromMap(response);
    } catch (e) {
      print('사용자 프로필 조회 실패: $e');
      return null;
    }
  }

  /// 현재 로그인된 사용자의 프로필을 조회합니다
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return getUserProfileById(user.id);
  }

  /// 사용자 프로필을 업데이트합니다
  Future<UserProfile?> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId)
          .select()
          .single();

      print('사용자 프로필 업데이트 성공: $userId');
      return UserProfile.fromMap(response);
    } catch (e) {
      print('사용자 프로필 업데이트 실패: $e');
      return null;
    }
  }

  /// 사용자의 마지막 활동 시간을 업데이트합니다
  Future<void> updateLastActiveAt(String userId) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({
            'last_active_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('마지막 활동 시간 업데이트 성공: $userId');
    } catch (e) {
      print('마지막 활동 시간 업데이트 실패: $e');
    }
  }

  /// FCM 토큰을 업데이트합니다
  Future<void> updateFcmToken(String userId, String fcmToken) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({
            'fcm_token': fcmToken,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('FCM 토큰 업데이트 성공: $userId');
    } catch (e) {
      print('FCM 토큰 업데이트 실패: $e');
    }
  }

  /// 푸시 알림 설정을 업데이트합니다
  Future<void> updatePushNotificationSetting(
    String userId,
    bool enabled,
  ) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({
            'push_notification_enabled': enabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('푸시 알림 설정 업데이트 성공: $userId - $enabled');
    } catch (e) {
      print('푸시 알림 설정 업데이트 실패: $e');
    }
  }

  /// 언어 설정을 업데이트합니다
  Future<void> updateLanguagePreference(String userId, String language) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({
            'language_preference': language,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('언어 설정 업데이트 성공: $userId - $language');
    } catch (e) {
      print('언어 설정 업데이트 실패: $e');
    }
  }

  /// 천사 데이터를 업데이트합니다
  Future<void> updateAngelData(
    String userId,
    Map<String, dynamic> angelData,
  ) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({
            'angel_data': angelData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('천사 데이터 업데이트 성공: $userId');
    } catch (e) {
      print('천사 데이터 업데이트 실패: $e');
    }
  }

  /// 경험치를 추가합니다
  Future<void> addExp(String userId, int exp) async {
    try {
      final currentProfile = await getUserProfileById(userId);
      if (currentProfile == null) return;

      final newExp = currentProfile.exp + exp;
      final newLevel = _calculateLevel(newExp);

      await _supabase
          .from('user_profiles')
          .update({
            'exp': newExp,
            'level': newLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('경험치 추가 성공: $userId - +$exp (총: $newExp, 레벨: $newLevel)');
    } catch (e) {
      print('경험치 추가 실패: $e');
    }
  }

  /// 도토리를 추가합니다
  Future<void> addAcorns(String userId, int acorns) async {
    try {
      final currentProfile = await getUserProfileById(userId);
      if (currentProfile == null) return;

      final newAcorns = currentProfile.acorns + acorns;

      await _supabase
          .from('user_profiles')
          .update({
            'acorns': newAcorns,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('도토리 추가 성공: $userId - +$acorns (총: $newAcorns)');
    } catch (e) {
      print('도토리 추가 실패: $e');
    }
  }

  /// 경험치에 따른 레벨을 계산합니다
  int _calculateLevel(int exp) {
    // 간단한 레벨 계산 공식 (필요에 따라 조정)
    return (exp / 100).floor() + 1;
  }

  /// 사용자 프로필을 삭제합니다
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase.from('user_profiles').delete().eq('id', userId);

      print('사용자 프로필 삭제 성공: $userId');
    } catch (e) {
      print('사용자 프로필 삭제 실패: $e');
    }
  }
}
