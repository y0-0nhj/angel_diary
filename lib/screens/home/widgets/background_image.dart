import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  String _getBackgroundImage() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 10) {
      return 'assets/images/backgrounds/희망의일출.png';
    } else if (hour >= 10 && hour < 17) {
      return 'assets/images/backgrounds/평온한하늘.png';
    } else if (hour >= 17 && hour < 20) {
      return 'assets/images/backgrounds/아름다운노을.png';
    } else {
      return 'assets/images/backgrounds/고요한별밤.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getBackgroundImage()),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
