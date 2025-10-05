// 체크리스트 항목을 위한 데이터 모델
class ChecklistItem {
  String text; // 항목 내용
  bool isCompleted; // 완료 여부

  ChecklistItem({required this.text, this.isCompleted = false});

  // JSON으로 변환 (Supabase에 저장할 때 사용)
  Map<String, dynamic> toJson() => {
    'text': text,
    'isCompleted': isCompleted,
  };

  // JSON에서 객체로 변환 (Supabase에서 불러올 때 사용)
  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    text: json['text'],
    isCompleted: json['isCompleted'],
  );
}