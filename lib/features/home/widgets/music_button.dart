import 'package:flutter/material.dart';

class MusicButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final VoidCallback onNext;

  const MusicButton({
    super.key,
    required this.isPlaying,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPlaying ? Colors.pink[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlaying ? Icons.music_note : Icons.music_off,
                  color: isPlaying ? Colors.pinkAccent : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isPlaying ? '음악 재생 중' : '음악 재생',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPlaying ? Colors.pinkAccent : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 다음 곡 버튼
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.skip_next, color: Colors.blue[600], size: 20),
          ),
        ),
      ],
    );
  }
}
