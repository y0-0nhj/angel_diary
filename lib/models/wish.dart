class Wish {
  final String id;
  final String userId;
  final String wishText;
  final DateTime createdAt;

  Wish({
    required this.id,
    required this.userId,
    required this.wishText,
    required this.createdAt,
  });

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      wishText: map['wish_text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'wish_text': wishText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {'wish_text': wishText};
  }

  Map<String, dynamic> toUpdateMap() {
    return {'wish_text': wishText};
  }

  Wish copyWith({
    String? id,
    String? userId,
    String? wishText,
    DateTime? createdAt,
  }) {
    return Wish(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wishText: wishText ?? this.wishText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Wish(id: $id, userId: $userId, wishText: $wishText, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wish &&
        other.id == id &&
        other.userId == userId &&
        other.wishText == wishText &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        wishText.hashCode ^
        createdAt.hashCode;
  }
}
