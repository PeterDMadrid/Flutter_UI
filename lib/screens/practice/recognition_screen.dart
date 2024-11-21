import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/screens/practice/widgets/choice_card.dart';

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
      body: Column(
        children: [
          const SizedBox(height: 45),
          const Center(
            child: Text(
              "Three",
              style: TextStyle(fontSize: 50),
            )
          ),
          GridView.count(
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0, 
            crossAxisCount: 2, 
            childAspectRatio: 1, 
            padding: const EdgeInsets.all(60.0), 
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const <Widget>[
              ChoiceCard(signImage: AppMedia.defaultProfilePhoto),
              ChoiceCard(signImage: AppMedia.defaultProfilePhoto),
              ChoiceCard(signImage: AppMedia.defaultProfilePhoto),
              ChoiceCard(signImage: AppMedia.defaultProfilePhoto),
            ],
          ),
        ],
      ),
    );
  }
}
