import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../main.dart' show textColor;

class TabSection extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const TabSection({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<TabSection> createState() => _TabSectionState();
}

class _TabSectionState extends State<TabSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // 탭 버튼들
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildTabButton(0, l10n.wishesTab, Colors.lightBlue[300]!),
                _buildTabButton(1, l10n.goalsTab, Colors.pink[200]!),
                _buildTabButton(2, l10n.gratitudeTab, Colors.yellow[400]!),
              ],
            ),
          ),

          // 내용 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 탭 콘텐츠는 부모 위젯에서 관리
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, Color color) {
    final isSelected = widget.selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
