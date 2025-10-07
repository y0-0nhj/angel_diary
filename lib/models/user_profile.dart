import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String? fcmToken;
  final bool pushNotificationEnabled;
  final String languagePreference;
  final int exp;
  final int level;
  final int acorns;
  final bool isPremiumUser;
  final String? currentAngelId;
  final String? currentIslandId;
  final Map<String, dynamic>? angelData;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.fcmToken,
    required this.pushNotificationEnabled,
    required this.languagePreference,
    required this.exp,
    required this.level,
    required this.acorns,
    required this.isPremiumUser,
    this.currentAngelId,
    this.currentIslandId,
    this.angelData,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      nickname: map['nickname'] as String,
      profileImageUrl: map['profile_image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastActiveAt: DateTime.parse(map['last_active_at'] as String),
      fcmToken: map['fcm_token'] as String?,
      pushNotificationEnabled: map['push_notification_enabled'] as bool,
      languagePreference: map['language_preference'] as String,
      exp: map['exp'] as int,
      level: map['level'] as int,
      acorns: map['acorns'] as int,
      isPremiumUser: map['is_premium_user'] as bool,
      currentAngelId: map['current_angel_id'] as String?,
      currentIslandId: map['current_island_id'] as String?,
      angelData: map['angel_data'] as Map<String, dynamic>?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
      'fcm_token': fcmToken,
      'push_notification_enabled': pushNotificationEnabled,
      'language_preference': languagePreference,
      'exp': exp,
      'level': level,
      'acorns': acorns,
      'is_premium_user': isPremiumUser,
      'current_angel_id': currentAngelId,
      'current_island_id': currentIslandId,
      'angel_data': angelData,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? fcmToken,
    bool? pushNotificationEnabled,
    String? languagePreference,
    int? exp,
    int? level,
    int? acorns,
    bool? isPremiumUser,
    String? currentAngelId,
    String? currentIslandId,
    Map<String, dynamic>? angelData,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      fcmToken: fcmToken ?? this.fcmToken,
      pushNotificationEnabled:
          pushNotificationEnabled ?? this.pushNotificationEnabled,
      languagePreference: languagePreference ?? this.languagePreference,
      exp: exp ?? this.exp,
      level: level ?? this.level,
      acorns: acorns ?? this.acorns,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      currentAngelId: currentAngelId ?? this.currentAngelId,
      currentIslandId: currentIslandId ?? this.currentIslandId,
      angelData: angelData ?? this.angelData,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
