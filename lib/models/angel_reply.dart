/// 천사 답장 모델
class AngelReply {
  final String id;
  final String letterId; // 원본 편지 ID
  final String content; // 천사 답장 내용
  final String emotion; // 천사가 선택한 감정
  final DateTime createdAt;
  final bool isRead; // 사용자가 읽었는지 여부

  AngelReply({
    required this.id,
    required this.letterId,
    required this.content,
    required this.emotion,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'letterId': letterId,
      'content': content,
      'emotion': emotion,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AngelReply.fromMap(Map<String, dynamic> map) {
    return AngelReply(
      id: map['id'] as String,
      letterId: map['letterId'] as String,
      content: map['content'] as String,
      emotion: map['emotion'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  AngelReply copyWith({
    String? id,
    String? letterId,
    String? content,
    String? emotion,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AngelReply(
      id: id ?? this.id,
      letterId: letterId ?? this.letterId,
      content: content ?? this.content,
      emotion: emotion ?? this.emotion,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 천사 답장 생성기
class AngelReplyGenerator {
  static final List<String> _encouragingMessages = [
    "정말 멋진 편지네요! 당신의 마음이 잘 전달될 거예요 💕",
    "편지를 쓰는 마음이 정말 따뜻해요. 받는 분이 기뻐하실 거예요 ✨",
    "당신의 진심이 느껴져요. 좋은 일들이 생길 거예요 🌟",
    "편지로 마음을 전하는 것, 정말 아름다운 일이에요 💌",
    "당신의 따뜻한 마음이 세상을 더 아름답게 만들어요 🌈",
    "편지를 받는 분이 얼마나 기뻐하실지 상상이 돼요 😊",
    "마음을 담은 편지, 정말 소중한 선물이에요 🎁",
    "당신의 진심이 전해질 거예요. 좋은 하루 되세요 ☀️",
  ];

  static final Map<String, List<String>> _emotionalReplies = {
    '😊': ["기쁜 마음이 전해져요! 당신도 행복한 하루 보내세요 😊", "웃음이 가득한 편지네요! 좋은 에너지가 느껴져요 ✨"],
    '😢': ["마음이 무거우시군요. 괜찮아요, 천사가 함께 있어요 🤗", "슬픈 마음이 이해돼요. 언제나 당신을 응원해요 💙"],
    '😍': ["사랑이 가득한 편지네요! 정말 아름다워요 💕", "사랑의 마음이 전해져요. 행복한 시간 되세요 🌹"],
    '🤔': [
      "고민이 있으시군요. 천천히 생각해보세요, 답이 나올 거예요 🤔",
      "생각이 많으시네요. 좋은 해결책이 있을 거예요 💭",
    ],
    '😴': ["피곤하시군요. 충분한 휴식을 취하세요 😴", "편안한 휴식이 필요하시네요. 잘 쉬어가세요 🌙"],
    '😤': ["화가 나시는군요. 깊게 숨을 쉬어보세요, 괜찮아질 거예요 😤", "짜증이 나시는군요. 천사가 당신을 안아줄게요 🤗"],
    '🥰': ["사랑스러운 마음이 전해져요! 정말 따뜻해요 🥰", "애정이 가득한 편지네요! 받는 분이 행복하실 거예요 💖"],
    '😭': ["눈물이 나는군요. 괜찮아요, 천사가 함께 있어요 😭", "마음이 아프시군요. 언제나 당신을 지켜줄게요 💙"],
  };

  static final List<String> _angelEmotions = [
    '😇',
    '👼',
    '✨',
    '🌟',
    '💫',
    '🕊️',
    '💝',
    '🎀',
  ];

  /// 편지 내용과 감정에 따라 천사 답장 생성
  static AngelReply generateReply(
    String letterContent,
    String userEmotion,
    String recipient,
  ) {
    final String replyContent = _generateContent(
      letterContent,
      userEmotion,
      recipient,
    );
    final String angelEmotion =
        _angelEmotions[DateTime.now().millisecondsSinceEpoch %
            _angelEmotions.length];

    return AngelReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      letterId: DateTime.now().millisecondsSinceEpoch.toString(),
      content: replyContent,
      emotion: angelEmotion,
      createdAt: DateTime.now(),
    );
  }

  static String _generateContent(
    String letterContent,
    String userEmotion,
    String recipient,
  ) {
    // 기본 격려 메시지
    String baseMessage =
        _encouragingMessages[DateTime.now().millisecondsSinceEpoch %
            _encouragingMessages.length];

    // 감정별 특별 메시지 추가
    if (_emotionalReplies.containsKey(userEmotion)) {
      final emotionalMessages = _emotionalReplies[userEmotion];
      if (emotionalMessages != null && emotionalMessages.isNotEmpty) {
        final emotionalMessage =
            emotionalMessages[DateTime.now().millisecondsSinceEpoch %
                emotionalMessages.length];
        baseMessage += "\n\n$emotionalMessage";
      }
    }

    // 받는 사람에 대한 특별 메시지
    if (recipient.isNotEmpty) {
      baseMessage += "\n\n$recipient님께 당신의 마음이 잘 전달될 거예요 💌";
    }

    return baseMessage;
  }
}
