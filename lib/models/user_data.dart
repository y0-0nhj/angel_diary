class UserData {
  final String userId;
  final String nickname;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String launguage;
  final String gender;

  UserData({
    required this.userId,
    required this.nickname,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.launguage,
    required this.gender,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      nickname: json['nickname'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      launguage: json['launguage'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'launguage': launguage,
      'gender': gender,
    };
  }
}
