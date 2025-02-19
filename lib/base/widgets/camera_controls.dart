import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleCamera;
  final bool isProcessing;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onToggleCamera,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.large(
              onPressed: isProcessing ? null : onCapture,
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.camera, size: 40,),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 40,
          child: FloatingActionButton(
            foregroundColor: AppStyles.textColor,
            backgroundColor: AppStyles.backgroundColor,
            onPressed: onToggleCamera,
            child: const Icon(Icons.flip_camera_ios_rounded),
          ),
        ),
      ],
    );
  }
}
