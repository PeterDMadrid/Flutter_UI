import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.choice,
    required this.onPressed,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  final String choice;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;

  String _getImagePath() {
    final index = int.tryParse(choice);
    if (index != null && index >= 0 && index <= 9) {
      return AppMedia.handsSign[index];
    }
    return AppMedia.defaultProfilePhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            // Bottom shadow for 3D depth
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 8),
              blurRadius: 10,
              spreadRadius: 0,
            ),
            // Subtle top light for 3D effect
            BoxShadow(
              color: Colors.lightBlue.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF102A43).withOpacity(0.7),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: showResult
                  ? (isCorrect
                      ? Colors.green
                      : (isSelected
                          ? Colors.red
                          : Colors.grey.withOpacity(0.3)))
                  : Colors.grey.withOpacity(0.3),
              width: 2.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF102A43).withOpacity(0.9),
                const Color(0xFF102A43).withOpacity(0.5),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    _getImagePath(),
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
