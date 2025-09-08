import 'package:flutter/material.dart';

// 메인 파일의 색상들을 가져다 쓰기 위해 import
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;

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
  
  // 드래그 모드 상태
  bool isDragMode = false;
  
  // 각 부위의 위치 오프셋 (단순화)
  Offset tailOffset = Offset.zero;
  Offset emotionOffset = Offset.zero;
  
  // 현재 선택된 부위 (미세 조정용)
  String? selectedPartForFineControl;
  
  // 미세 조정 스텝 크기
  double fineControlStepSize = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
        actions: [
          // 드래그 모드 토글 버튼
          IconButton(
            icon: Icon(
              isDragMode ? Icons.pan_tool : Icons.open_with,
              color: isDragMode ? primaryColor : textColor,
            ),
            onPressed: () {
              setState(() {
                isDragMode = !isDragMode;
              });
            },
            tooltip: isDragMode ? '드래그 모드 끄기' : '드래그 모드 켜기',
          ),
          // 위치 리셋 버튼
          if (isDragMode)
            IconButton(
              icon: const Icon(Icons.refresh, color: textColor),
              onPressed: () {
                setState(() {
                  tailOffset = Offset.zero;
                  emotionOffset = Offset.zero;
                });
              },
              tooltip: '위치 초기화',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 캐릭터 미리보기 영역
            Container(
              height: 300, // 고정 높이로 설정
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                  isDragMode: isDragMode,
                  tailOffset: tailOffset,
                  emotionOffset: emotionOffset,
                  onTailDrag: (offset) => setState(() => tailOffset = offset),
                  onEmotionDrag: (offset) => setState(() => emotionOffset = offset),
                ),
              ),
            ),
            
            // 드래그 모드 안내 및 미세 조정 컨트롤
            if (isDragMode) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '드래그 모드가 활성화되었습니다. 부위를 선택하고 미세 조정 버튼을 사용해보세요!',
                        style: TextStyle(color: primaryColor, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 부위 선택 버튼들
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('미세 조정할 부위 선택:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPartSelectButton('표정', 'emotion'),
                        const SizedBox(width: 10),
                        _buildPartSelectButton('꼬리', 'tail'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 미세 조정 컨트롤
              if (selectedPartForFineControl != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_getPartDisplayName(selectedPartForFineControl!)} 미세 조정',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 15),
                      _buildFineControlPad(),
                    ],
                  ),
                ),
            ],
            
            // 커스터마이징 컨트롤 영역 (단순화)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 얼굴 타입 선택 (1-4)
                  _buildPartSelector('얼굴 타입', faceTypeCount, selectedFaceType, (index) {
                    setState(() {
                      selectedFaceType = index;
                    });
                  }),
                  const SizedBox(height: 15),

                  // 얼굴 색상 선택 (1-6)
                  _buildPartSelector('얼굴 색상', faceColorCount, selectedFaceColor, (index) {
                    setState(() {
                      selectedFaceColor = index;
                    });
                  }),
                  const SizedBox(height: 15),

                  // 몸통 선택 (1-6)
                  _buildPartSelector('몸통', bodyCount, selectedBodyIndex, (index) {
                    setState(() => selectedBodyIndex = index);
                  }),
                  const SizedBox(height: 15),

                  // 표정 선택 (1-4)
                  _buildPartSelector('표정', emotionCount, selectedEmotionIndex, (index) {
                    setState(() => selectedEmotionIndex = index);
                  }),
                  const SizedBox(height: 15),
                  
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
    );
  }

  Widget _buildPartSelector(String title, int count, int selectedIndex, Function(int) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Container(
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

  // 부위 선택 버튼 생성
  Widget _buildPartSelectButton(String displayName, String partKey) {
    final isSelected = selectedPartForFineControl == partKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPartForFineControl = isSelected ? null : partKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 부위 이름 표시용 헬퍼
  String _getPartDisplayName(String partKey) {
    switch (partKey) {
      case 'emotion': return '표정';
      case 'tail': return '꼬리';
      default: return partKey;
    }
  }

  // 미세 조정 컨트롤 패드
  Widget _buildFineControlPad() {
    return Column(
      children: [
        // 스텝 크기 조정
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이동 크기:', style: TextStyle(fontSize: 12, color: textColor)),
            const SizedBox(width: 10),
            ...([0.5, 1.0, 2.0, 5.0].map((step) => 
              GestureDetector(
                onTap: () => setState(() => fineControlStepSize = step),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: fineControlStepSize == step ? primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${step}px',
                    style: TextStyle(
                      fontSize: 10,
                      color: fineControlStepSize == step ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 15),
        
        // 위쪽 버튼
        _buildDirectionButton(Icons.keyboard_arrow_up, () => _adjustPosition(0, -fineControlStepSize)),
        const SizedBox(height: 5),
        
        // 좌우 버튼과 가운데 리셋 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDirectionButton(Icons.keyboard_arrow_left, () => _adjustPosition(-fineControlStepSize, 0)),
            _buildDirectionButton(Icons.center_focus_strong, () => _resetSelectedPartPosition()),
            _buildDirectionButton(Icons.keyboard_arrow_right, () => _adjustPosition(fineControlStepSize, 0)),
          ],
        ),
        
        const SizedBox(height: 5),
        // 아래쪽 버튼
        _buildDirectionButton(Icons.keyboard_arrow_down, () => _adjustPosition(0, fineControlStepSize)),
        
        const SizedBox(height: 10),
        // 현재 위치 표시
        Text(
          '현재 위치: ${_getCurrentOffset().dx.toStringAsFixed(1)}, ${_getCurrentOffset().dy.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12, color: secondaryColor),
        ),
      ],
    );
  }

  // 방향 버튼 생성
  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 24),
      ),
    );
  }

  // 위치 조정 메서드
  void _adjustPosition(double deltaX, double deltaY) {
    if (selectedPartForFineControl == null) return;
    
    setState(() {
      final currentOffset = _getCurrentOffset();
      final newOffset = Offset(
        (currentOffset.dx + deltaX).clamp(-50.0, 50.0),
        (currentOffset.dy + deltaY).clamp(-50.0, 50.0),
      );
      _setCurrentOffset(newOffset);
    });
  }

  // 선택된 부위 위치 리셋
  void _resetSelectedPartPosition() {
    if (selectedPartForFineControl == null) return;
    
    setState(() {
      _setCurrentOffset(Offset.zero);
    });
  }

  // 현재 선택된 부위의 오프셋 가져오기
  Offset _getCurrentOffset() {
    switch (selectedPartForFineControl) {
      case 'emotion': return emotionOffset;
      case 'tail': return tailOffset;
      default: return Offset.zero;
    }
  }

  // 현재 선택된 부위의 오프셋 설정
  void _setCurrentOffset(Offset offset) {
    switch (selectedPartForFineControl) {
      case 'emotion': 
        emotionOffset = offset;
        break;
      case 'tail': 
        tailOffset = offset;
        break;
    }
  }

}

class CharacterView extends StatelessWidget {
  final String animalType;
  final int faceType;
  final int faceColor;
  final int bodyIndex;
  final int emotionIndex;
  final int tailIndex;
  final bool isDragMode;
  final Offset tailOffset;
  final Offset emotionOffset;
  final Function(Offset)? onTailDrag;
  final Function(Offset)? onEmotionDrag;
  
  const CharacterView({
    super.key,
    required this.animalType,
    required this.faceType,
    required this.faceColor,
    required this.bodyIndex,
    required this.emotionIndex,
    required this.tailIndex,
    this.isDragMode = false,
    this.tailOffset = Offset.zero,
    this.emotionOffset = Offset.zero,
    this.onTailDrag,
    this.onEmotionDrag,
  });

  String _getImagePath(String part) {
    switch (part) {
      case 'body':
        // 몸통
        return 'assets/images/characters/$animalType/body/${bodyIndex}.png';
      case 'face':
        // 얼굴은 타입-색상 형태
        return 'assets/images/characters/$animalType/face/$faceType-$faceColor.png';
      case 'emotion':
        // 표정
        return 'assets/images/characters/$animalType/emotion/${emotionIndex}.png';
      case 'tail':
        // 꼬리는 선택된 타입과 얼굴 색상 적용
        return 'assets/images/characters/$animalType/tail/$tailIndex-$faceColor.png';
      default:
        return 'assets/images/characters/$animalType/body/1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // 드래그 시 경계를 벗어날 수 있도록
        children: [
          // 1. 몸통 (맨 아래 베이스, 고정)
          Positioned(
            left: 0,
            top: 20,
            child: Image.asset(
              _getImagePath('body'),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          
          // 2. 얼굴 (고정, 몸통 위쪽에 배치)
          Positioned(
            left: 25,
            top: -10,
            child: Image.asset(
              _getImagePath('face'),
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          
          // 3. 드래그 가능한 꼬리 (뒤쪽에 배치)
          Positioned(
            left: -75,
            child: Image.asset(
              _getImagePath('tail'),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          
          // 4. 드래그 가능한 표정 (얼굴 위)
            Positioned(
            left: 70,
            top: 50,
            child: Image.asset(
              _getImagePath('emotion'),
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePart({
    required Widget child,
    required Offset offset,
    required Function(Offset)? onDrag,
    required bool isDragMode,
    Offset defaultPosition = Offset.zero,
  }) {
    // 최종 위치 = 기본 위치 + 사용자 조정 오프셋
    final finalOffset = defaultPosition + offset;
    
    if (!isDragMode || onDrag == null) {
      // 드래그 모드가 아닐 때는 일반적인 Transform으로 위치만 적용
      return Transform.translate(
        offset: finalOffset,
        child: child,
      );
    }
    
    return Positioned(
      left: 100 + finalOffset.dx - 100, // 중앙 기준으로 최종 오프셋 적용
      top: 100 + finalOffset.dy - 100,
      child: Builder(
        builder: (BuildContext context) {
          return Draggable<String>(
            data: 'part',
            feedback: Opacity(
              opacity: 0.7,
              child: child,
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: child,
            ),
            onDragEnd: (details) {
              // 드래그 완료 시 최종 위치 계산
              final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(details.offset);
                
                // 캐릭터 뷰 중앙을 기준으로 오프셋 계산하고 기본 위치를 빼서 사용자 조정분만 저장
                final newOffset = Offset(
                  localPosition.dx - 100 - defaultPosition.dx,
                  localPosition.dy - 100 - defaultPosition.dy,
                );
                
                // 경계 제한 (-50 ~ 50 범위로 제한)
                final constrainedOffset = Offset(
                  newOffset.dx.clamp(-50.0, 50.0),
                  newOffset.dy.clamp(-50.0, 50.0),
                );
                
                onDrag(constrainedOffset);
              }
            },
            child: Container(
              decoration: isDragMode ? BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(8),
              ) : null,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

