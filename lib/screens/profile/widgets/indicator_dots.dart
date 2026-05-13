import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class IndicatorDots extends StatelessWidget {
  final int currentAdditionPage;
  final int totalLevels;

  const IndicatorDots({
    super.key,
    required this.currentAdditionPage,
    required this.totalLevels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalLevels,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentAdditionPage == index ? 16 : 8,
          decoration: BoxDecoration(
            color: currentAdditionPage == index
                ? AppStyles.khaki
                : AppStyles.khaki.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
