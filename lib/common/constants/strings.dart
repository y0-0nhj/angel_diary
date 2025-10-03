class AppStrings {
  // 앱 일반
  static const String appName = '천사일기';

  // 메시지 (기존 home.dart와 home_screen.dart에서 사용 중)
  static const List<Map<String, String>> inspirationalMessages = [
    {'text': '하나님이 너와 함께 하시니라', 'source': '창세기 28:15'},
    {'text': '내가 너를 위하여 정한 계획은 평안이요 재앙이 아니니라', 'source': '예레미야 29:11'},
    {'text': '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'source': '시편 23:1'},
    {'text': '모든 일이 합력하여 선을 이룬다', 'source': '로마서 8:28'},
  ];

  static const List<String> encouragementMessages = [
    '정말 잘하고 있어요! 💪',
    '훌륭해요! 계속 이렇게 해요! ✨',
    '오늘도 멋진 하루를 보내고 있네요! 🌟',
    '정말 대단해요! 자랑스러워요! 👏',
    '완벽해요! 정말 잘했어요! 🎉',
  ];

  // 오류 메시지
  static const String errorLoadingData = '데이터를 불러오는 중 오류가 발생했습니다.';
  static const String errorSavingData = '데이터를 저장하는 중 오류가 발생했습니다.';

  // 확인 메시지
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String confirmReset = '모든 데이터를 초기화하시겠습니까?';
}
