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
  
  // 드래그 기능 제거됨 - 모든 부위 고정

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
        // 드래그 기능 제거로 액션 버튼 없음
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
                ),
              ),
            ),
            
            // 드래그 기능 제거됨
            
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

  // 드래그 관련 메서드들 제거됨

}

class CharacterView extends StatelessWidget {
  final String animalType;
  final int faceType;
  final int faceColor;
  final int bodyIndex;
  final int emotionIndex;
  final int tailIndex;
  
  const CharacterView({
    super.key,
    required this.animalType,
    required this.faceType,
    required this.faceColor,
    required this.bodyIndex,
    required this.emotionIndex,
    required this.tailIndex,
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
            left: -30,
            top: 0,
            child: Image.asset(
              _getImagePath('body'),
              width: 250,
              height: 250,
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

  // 드래그 기능 제거로 _buildDraggablePart 메서드 삭제됨
}

