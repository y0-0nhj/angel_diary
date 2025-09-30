import 'package:flutter/material.dart';

/// 고정된 너비를 가진 반응형 레이아웃 위젯
class FixedWidthLayout extends StatelessWidget {
  final Widget child;
  final double contentWidth;
  final Color backgroundColor;
  final Color contentColor;
  final EdgeInsetsGeometry padding;

  const FixedWidthLayout({
    super.key,
    required this.child,
    this.contentWidth = 350,
    this.backgroundColor = const Color(0xFFE0E0E0), // Colors.grey[200]
    this.contentColor = Colors.white,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Center(
          child: Container(
            width: contentWidth,
            color: contentColor,
            child: SingleChildScrollView(
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 반응형 레이아웃 설정을 관리하는 클래스
class ResponsiveLayoutConfig {
  /// 기본 컨텐츠 너비
  static const double defaultContentWidth = 350.0;

  /// 기본 패딩
  static const EdgeInsets defaultPadding = EdgeInsets.all(20.0);

  /// 기본 배경색
  static final Color defaultBackgroundColor = Colors.grey[200]!;

  /// 화면 크기에 따른 컨텐츠 너비 계산
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 740) {
      return 740.0; // 폴드4 최대 폭
    } else if (screenWidth >= 400) {
      return screenWidth * 0.95; // 일반 폰 가로 모드
    } else {
      return screenWidth * 0.9; // 일반 폰 세로 모드
    }
  }

  /// 화면 크기에 따른 패딩 계산
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return const EdgeInsets.all(10.0);
    }
    return defaultPadding;
  }
}
