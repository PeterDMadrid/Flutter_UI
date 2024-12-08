import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.choice, required this.onPressed});

  final String choice;
  final VoidCallback onPressed;

  String _getImagePath() {
    final index = int.tryParse(choice);
    if (index != null && index >= 0 && index <= 9) {
      return AppMedia.handsSign[index];
    }
    return AppMedia.defaultProfilePhoto;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dynamicSize = constraints.maxWidth * 1; // 25% of parent width

        return Center(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(24.0),
              minimumSize: const Size(100, 100),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Image.asset(
              _getImagePath(),
              width: dynamicSize,
              height: dynamicSize,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
