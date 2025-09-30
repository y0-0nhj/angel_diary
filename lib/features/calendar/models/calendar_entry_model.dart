class CalendarEntry {
  final String date;
  final List<Map<String, dynamic>> wishes;
  final List<Map<String, dynamic>> goals;
  final List<Map<String, dynamic>> gratitudes;
  final String? diary;

  CalendarEntry({
    required this.date,
    required this.wishes,
    required this.goals,
    required this.gratitudes,
    this.diary,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'wishes': wishes,
      'goals': goals,
      'gratitudes': gratitudes,
      'diary': diary,
    };
  }

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      date: json['date'],
      wishes: List<Map<String, dynamic>>.from(json['wishes'] ?? []),
      goals: List<Map<String, dynamic>>.from(json['goals'] ?? []),
      gratitudes: List<Map<String, dynamic>>.from(json['gratitudes'] ?? []),
      diary: json['diary'],
    );
  }

  CalendarEntry copyWith({
    String? date,
    List<Map<String, dynamic>>? wishes,
    List<Map<String, dynamic>>? goals,
    List<Map<String, dynamic>>? gratitudes,
    String? diary,
  }) {
    return CalendarEntry(
      date: date ?? this.date,
      wishes: wishes ?? this.wishes,
      goals: goals ?? this.goals,
      gratitudes: gratitudes ?? this.gratitudes,
      diary: diary ?? this.diary,
    );
  }
}
