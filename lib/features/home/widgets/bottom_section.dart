import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../main.dart' show primaryColor;

class BottomSection extends StatelessWidget {
  final VoidCallback onDiaryEdit;
  final VoidCallback onCalendarTap;
  final bool hasDiary;

  const BottomSection({
    super.key,
    required this.onDiaryEdit,
    required this.onCalendarTap,
    required this.hasDiary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 일기 쓰기/수정 버튼 (왼쪽)
          Expanded(
            child: ElevatedButton(
              onPressed: onDiaryEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasDiary ? Icons.edit : Icons.edit_note, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    hasDiary ? l10n.editDiary : l10n.writeDiary,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 캘린더 아이콘 (오른쪽)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: onCalendarTap,
              icon: const Icon(
                Icons.calendar_today,
                size: 28,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
