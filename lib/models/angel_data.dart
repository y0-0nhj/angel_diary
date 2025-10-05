/// 천사 데이터 모델
/// 
/// 천사의 모든 속성과 JSON 변환 기능을 포함합니다.
class AngelData {
  final String name;
  final String feature;
  final String animalType;
  final int faceType;
  final int faceColor;
  final int bodyIndex;
  final int emotionIndex;
  final int tailIndex;
  final DateTime createdAt;

  AngelData({
    required this.name,
    required this.feature,
    required this.animalType,
    required this.faceType,
    required this.faceColor,
    required this.bodyIndex,
    required this.emotionIndex,
    required this.tailIndex,
    required this.createdAt,
  });

  /// JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'feature': feature,
      'animalType': animalType,
      'faceType': faceType,
      'faceColor': faceColor,
      'bodyIndex': bodyIndex,
      'emotionIndex': emotionIndex,
      'tailIndex': tailIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON에서 AngelData 객체를 생성하는 팩토리 생성자
  factory AngelData.fromJson(Map<String, dynamic> json) {
    return AngelData(
      name: json['name'],
      feature: json['feature'],
      animalType: json['animalType'],
      faceType: json['faceType'],
      faceColor: json['faceColor'],
      bodyIndex: json['bodyIndex'],
      emotionIndex: json['emotionIndex'],
      tailIndex: json['tailIndex'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}