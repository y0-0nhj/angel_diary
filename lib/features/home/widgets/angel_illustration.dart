import 'package:flutter/material.dart';
import '../../../models/angel_data.dart';
import '../../../character_view.dart';

class AngelIllustration extends StatelessWidget {
  final AngelData? angelData;
  final int emotionIndex;
  final Function(int) onEmotionChanged;

  const AngelIllustration({
    super.key,
    this.angelData,
    required this.emotionIndex,
    required this.onEmotionChanged,
  });

  String _getBackgroundImage() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 10) {
      // 새벽 ~ 아침 (05:00 ~ 10:00)
      return 'assets/images/backgrounds/희망의일출.png';
    } else if (hour >= 10 && hour < 17) {
      // 낮 (10:00 ~ 17:00)
      return 'assets/images/backgrounds/평온한하늘.png';
    } else if (hour >= 17 && hour < 20) {
      // 저녁 (17:00 ~ 20:00)
      return 'assets/images/backgrounds/아름다운노을.png';
    } else {
      // 밤 (20:00 ~ 05:00)
      return 'assets/images/backgrounds/고요한별밤.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 시간대별 배경
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 투명한 천사 이미지
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/backgrounds/crt_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 천사 캐릭터
          Positioned(
            left: 0,
            right: 0,
            top: 140,
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: _buildAngelCharacter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAngelCharacter() {
    if (angelData == null) {
      return const Center(child: Text('🐱', style: TextStyle(fontSize: 60)));
    }

    return Center(
      child: CharacterView(
        animalType: angelData!.animalType,
        faceType: angelData!.faceType,
        faceColor: angelData!.faceColor,
        bodyIndex: angelData!.bodyIndex,
        emotionIndex: emotionIndex,
        tailIndex: angelData!.tailIndex,
        enableTailAnimation: true,
        scaleFactor: 0.61,
        onEmotionChanged: onEmotionChanged,
      ),
    );
  }
}
