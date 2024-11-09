import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  void _showInstructions() {
    _overlayEntry = OverlayEntry(
        builder: (context) => Instructions(
              onGotIt: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
              },
              instructionContent: "Recognition inst",
            ));

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognition Practice'),
      ),
    );
  }
}
