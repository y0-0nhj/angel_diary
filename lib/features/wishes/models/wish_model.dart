class Wish {
  final String id;
  final String text;
  final String category;
  final DateTime createdAt;
  final bool isCompleted;

  Wish({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['id'],
      text: json['text'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Wish copyWith({String? text, String? category, bool? isCompleted}) {
    return Wish(
      id: id,
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
