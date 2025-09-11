import 'package:flutter/material.dart';
import 'main.dart';

class CharacterCustomizationScreen extends StatefulWidget {
  final String animalType; // 'cat' 또는 'dog'
  
  const CharacterCustomizationScreen({super.key, this.animalType = 'dog'});

  @override
  State<CharacterCustomizationScreen> createState() => _CharacterCustomizationScreenState();
}

class _CharacterCustomizationScreenState extends State<CharacterCustomizationScreen> {
  // 현재 선택된 파츠 인덱스들 (단순화)

  int selectedFaceType = 1; // 얼굴 타입 (1-4)
  int selectedFaceColor = 1; // 얼굴 색상 (1-6)
  int selectedBodyIndex = 1; // 몸통 (1-6)
  int selectedEmotionIndex = 1; // 표정 (1-4)
  int selectedTailIndex = 1; // 꼬리 (1-4)
  
  // 파츠별 개수 (실제 에셋에 맞춰 설정)
  final int faceTypeCount = 4; // 얼굴 타입 개수 (1-4)
  final int faceColorCount = 6; // 얼굴 색상 개수 (1-6)
  final int bodyCount = 6; // 몸통 개수 (1-6)
  final int emotionCount = 4; // 표정 개수 (1-4)
  final int tailCount = 4; // 꼬리 개수 (1-4)
  
  // 드래그 기능 제거됨 - 모든 부위 고정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.animalType == 'cat' ? '고양이' : '강아지'} 커스터마이징',
          style: const TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // 드래그 기능 제거로 액션 버튼 없음
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(34.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            // 캐릭터 미리보기 영역
            Container(
              height: 150, // 300 * 0.5 = 150 (고정 높이로 설정)
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: CharacterView(
                  animalType: widget.animalType,
                  faceType: selectedFaceType,
                  faceColor: selectedFaceColor,
                  bodyIndex: selectedBodyIndex,
                  emotionIndex: selectedEmotionIndex,
                  tailIndex: selectedTailIndex,
                ),
              ),
            ),
            
            // 드래그 기능 제거됨
            
            // 커스터마이징 컨트롤 영역 (단순화)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  // 귀 타입 선택 (1-4)
                  _buildPartSelector('귀 타입', faceTypeCount, selectedFaceType, (index) {
                    setState(() {
                      selectedFaceType = index;
                      
                    });
                  }),
                  const SizedBox(height: 15),

                  // 패턴 색상 선택 (1-6)
                  _buildPartSelector('패턴 색상', faceColorCount, selectedFaceColor, (index) {
                    setState(() {
                      selectedFaceColor = index;
                    });
                  }),
                  const SizedBox(height: 15),

                  // // 몸통 선택 (1-6)
                  // _buildPartSelector('몸통', bodyCount, selectedBodyIndex, (index) {
                  //   setState(() => selectedBodyIndex = index);
                  // }),
                  // const SizedBox(height: 15),

                  // // 표정 선택 (1-4)
                  // _buildPartSelector('표정', emotionCount, selectedEmotionIndex, (index) {
                  //   setState(() => selectedEmotionIndex = index);
                  // }),
                  // const SizedBox(height: 15),
                  
                  // 꼬리 선택 (1-4)
                  _buildPartSelector('꼬리', tailCount, selectedTailIndex, (index) {
                    setState(() => selectedTailIndex = index);
                  }),
                ],
              ),
            ),
            
            // 완료 버튼
            Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  // TODO: 커스터마이징 완료 로직
                  Navigator.pop(context);
                },
                child: const Text("완료", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20), // 하단 여백 추가
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartSelector(String title, int count, int selectedIndex, Function(int) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final itemIndex = index + 1;
              return GestureDetector(
                onTap: () => onSelect(itemIndex),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == itemIndex ? primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedIndex == itemIndex ? primaryColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$itemIndex',
                      style: TextStyle(
                        color: selectedIndex == itemIndex ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 드래그 관련 메서드들 제거됨

}

class CharacterView extends StatefulWidget {
  final String animalType;
  final int faceType;
  final int faceColor;
  final int bodyIndex;
  final int emotionIndex;
  final int tailIndex;
  final bool enableTailAnimation; // 꼬리 애니메이션 활성화 여부
  final Function(int)? onEmotionChanged; // 표정 변경 콜백
  
  const CharacterView({
    super.key,
    required this.animalType,
    required this.faceType,
    required this.faceColor,
    required this.bodyIndex,
    required this.emotionIndex,
    required this.tailIndex,
    this.enableTailAnimation = false, // 기본값은 false
    this.onEmotionChanged, // 표정 변경 콜백
  });

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> 
    with TickerProviderStateMixin {
  late AnimationController _tailAnimationController;
  late Animation<double> _tailAnimation;
  late AnimationController _breathingAnimationController;
  late Animation<double> _breathingAnimation;
  
  // 현재 표정 상태 (드래그 중 변경 가능)
  int _currentEmotionIndex = 1; // 기본값으로 초기화
  DateTime? _lastEmotionChangeTime; // 마지막 표정 변경 시간

  @override
  void initState() {
    super.initState();
    
    // 현재 표정 초기화 (기본값이 이미 설정되어 있으므로 widget 값으로 덮어쓰기)
    _currentEmotionIndex = widget.emotionIndex;
    
    // 꼬리 애니메이션 컨트롤러
    _tailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 3초 주기
      vsync: this,
    );
    
    // 꼬리가 -15도에서 +15도까지 흔들리는 애니메이션
    _tailAnimation = Tween<double>(
      begin: -0.16, // -15도 (라디안)
      end: 0.16,    // +15도 (라디안)
    ).animate(CurvedAnimation(
      parent: _tailAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 몸통 호흡 애니메이션 컨트롤러
    _breathingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000), // 4초 주기 (호흡 리듬)
      vsync: this,
    );
    
    // 몸통이 1.0에서 1.1배까지 크고 작아지는 애니메이션
    _breathingAnimation = Tween<double>(
      begin: 1.0,   // 원래 크기
      end: 1.05,    // 5% 커짐
    ).animate(CurvedAnimation(
      parent: _breathingAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 애니메이션이 활성화되어 있으면 시작
    if (widget.enableTailAnimation) {
      _startTailAnimation();
      _startBreathingAnimation();
    }
  }

  @override
  void didUpdateWidget(CharacterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 표정이 변경되면 현재 표정 업데이트
    if (widget.emotionIndex != oldWidget.emotionIndex) {
      _currentEmotionIndex = widget.emotionIndex;
    }
    
    // 애니메이션 활성화 상태가 변경되면 처리
    if (widget.enableTailAnimation != oldWidget.enableTailAnimation) {
      if (widget.enableTailAnimation) {
        _startTailAnimation();
        _startBreathingAnimation();
      } else {
        _stopTailAnimation();
        _stopBreathingAnimation();
      }
    }
  }

  @override
  void dispose() {
    _tailAnimationController.dispose();
    _breathingAnimationController.dispose();
    super.dispose();
  }

  void _startTailAnimation() {
    _tailAnimationController.repeat(reverse: true);
  }

  void _stopTailAnimation() {
    _tailAnimationController.stop();
    _tailAnimationController.reset();
  }

  void _startBreathingAnimation() {
    _breathingAnimationController.repeat(reverse: true);
  }

  void _stopBreathingAnimation() {
    _breathingAnimationController.stop();
    _breathingAnimationController.reset();
  }

  // 랜덤 표정 변경 메서드 (2초 간격으로 제한)
  void _changeRandomEmotion() {
    final now = DateTime.now();
    
    // 마지막 변경 시간이 없거나 2초가 지났을 때만 변경
    if (_lastEmotionChangeTime == null || 
        now.difference(_lastEmotionChangeTime!).inMilliseconds >= 1000) {
      
      final random = now.millisecondsSinceEpoch % 4 + 1; // 1-4 랜덤
      if (random != _currentEmotionIndex) {
        setState(() {
          _currentEmotionIndex = random;
          _lastEmotionChangeTime = now; // 변경 시간 기록
        });
        // 콜백 호출
        widget.onEmotionChanged?.call(random);
      }
    }
  }

  // 기본 표정(1번)으로 리셋 메서드
  void _resetToDefaultEmotion() {
    if (_currentEmotionIndex != 1) {
      setState(() {
        _currentEmotionIndex = 1;
        _lastEmotionChangeTime = DateTime.now(); // 리셋 시간도 기록
      });
      // 콜백 호출
      widget.onEmotionChanged?.call(1);
    }
  }

  String _getImagePath(String part) {
    switch (part) {
      case 'body':
        // 몸통
        return 'assets/images/characters/${widget.animalType}/body/${widget.faceColor}.png';
      case 'face':
        // 얼굴은 타입-색상 형태
        return 'assets/images/characters/${widget.animalType}/face/${widget.faceType}-${widget.faceColor}.png';
      case 'emotion':
        // 표정 (현재 표정 사용)
        return 'assets/images/characters/${widget.animalType}/emotion/$_currentEmotionIndex.png';
      case 'tail':
        // 꼬리는 선택된 타입과 얼굴 색상 적용
        return 'assets/images/characters/${widget.animalType}/tail/${widget.tailIndex}-${widget.faceColor}.png';
      default:
        return 'assets/images/characters/${widget.animalType}/body/1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 천사 크기를 절반으로 줄이기 위한 스케일 팩터
    const double scaleFactor = 0.5;
    
    double tailWidth = 200 * scaleFactor;
    double tailHeight = 200 * scaleFactor;
    double tailLeft = -75 * scaleFactor;
    double tailTop = 0;

    if(widget.animalType == 'cat') {
    if(widget.tailIndex == 3) {
      tailWidth = 80 * scaleFactor; // 꼬리 3번의 너비를 더 작게
      tailHeight = 80 * scaleFactor; // 꼬리 3번의 높이를 더 작게
      tailLeft = -35 * scaleFactor; // 꼬리 3번의 왼쪽 위치 조정 (더 안쪽으로)
      tailTop = 130 * scaleFactor; // 꼬리 3번의 위쪽 위치 조정 (더 위로)
    }
  } else if(widget.animalType == 'dog') {
    if(widget.tailIndex == 1) {
      tailWidth = 140 * scaleFactor; // 꼬리 3번의 너비를 더 작게
      tailHeight = 140 * scaleFactor; // 꼬리 3번의 높이를 더 작게
      tailLeft = -70 * scaleFactor; // 꼬리 3번의 왼쪽 위치 조정 (더 안쪽으로)
      tailTop = 70 * scaleFactor; // 꼬리 3번의 위쪽 위치 조정 (더 위로)
    }
    if(widget.tailIndex == 2) {
      tailWidth = 140 * scaleFactor; // 꼬리 3번의 너비를 더 작게
      tailHeight = 140 * scaleFactor; // 꼬리 3번의 높이를 더 작게
      tailLeft = -70 * scaleFactor; // 꼬리 3번의 왼쪽 위치 조정 (더 안쪽으로)
      tailTop = 70 * scaleFactor; // 꼬리 3번의 위쪽 위치 조정 (더 위로)
    }
    if(widget.tailIndex == 3) {
      tailWidth = 140 * scaleFactor; // 꼬리 3번의 너비를 더 작게
      tailHeight = 140 * scaleFactor; // 꼬리 3번의 높이를 더 작게
      tailLeft = -70 * scaleFactor; // 꼬리 3번의 왼쪽 위치 조정 (더 안쪽으로)
      tailTop = 70 * scaleFactor; // 꼬리 3번의 위쪽 위치 조정 (더 위로)
    }
    if(widget.tailIndex == 4) {
      tailWidth = 170 * scaleFactor; // 꼬리 3번의 너비를 더 작게
      tailHeight = 170 * scaleFactor; // 꼬리 3번의 높이를 더 작게
      tailLeft = -75 * scaleFactor; // 꼬리 3번의 왼쪽 위치 조정 (더 안쪽으로)
      tailTop = 70 * scaleFactor; // 꼬리 3번의 위쪽 위치 조정 (더 위로)
    }
  }
  
    return SizedBox(
      width: 200 * scaleFactor,
      height: 200 * scaleFactor,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // 드래그 시 경계를 벗어날 수 있도록
        children: [
                    
          // 1. 애니메이션 가능한 꼬리 (뒤쪽에 배치)
          Positioned(
            left: tailLeft,
            top: tailTop,
            child: AnimatedBuilder(
              animation: _tailAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: widget.enableTailAnimation ? _tailAnimation.value : 0.0,
                  child: Image.asset(
                    _getImagePath('tail'),
                    width: tailWidth,
                    height: tailHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                );
              },
            ),
          ),
          
          // 2. 몸통 (맨 아래 베이스, 호흡 애니메이션 적용)
          Positioned(
            left: -30 * scaleFactor,
            top: 0,
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.enableTailAnimation ? _breathingAnimation.value : 1.0,
                  child: Image.asset(
                    _getImagePath('body'),
                    width: 250 * scaleFactor,
                    height: 250 * scaleFactor,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200 * scaleFactor,
                        height: 200 * scaleFactor,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          // 3. 얼굴 (드래그 가능, 몸통 위쪽에 배치)
          Positioned(
            left: 25 * scaleFactor,
            top: -10 * scaleFactor,
            child: GestureDetector(
              onPanUpdate: (details) {
                // 드래그 중 랜덤 표정 변경
                _changeRandomEmotion();
              },
              onPanEnd: (details) {
                // 드래그가 끝나면 1번 표정으로 돌아가기
                _resetToDefaultEmotion();
              },
              child: Image.asset(
                _getImagePath('face'),
                width: 180 * scaleFactor,
                height: 180 * scaleFactor,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // 4. 드래그 가능한 표정 (얼굴 위)
            Positioned(
            left: 70 * scaleFactor,
            top: 50 * scaleFactor,
            child: Image.asset(
              _getImagePath('emotion'),
              width: 100 * scaleFactor,
              height: 100 * scaleFactor,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

}

