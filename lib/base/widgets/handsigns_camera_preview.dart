import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class HandSignCameraPreview extends StatelessWidget {
  final CameraController? cameraController;
  final File? capturedImageFile;
  final bool showCapturedImage;
  final bool isFrontCamera;

  const HandSignCameraPreview({
    super.key,
    required this.cameraController,
    this.capturedImageFile,
    this.showCapturedImage = false,
    required this.isFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppStyles.buttonColor,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: showCapturedImage && capturedImageFile != null
                ? Transform.flip(
                    flipX: isFrontCamera ? false : true,
                    child: Image.file(
                      capturedImageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : cameraController != null && cameraController!.value.isInitialized 
                    ? CameraPreview(cameraController!)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
          ),
        ),
      ),
    );
  }
}