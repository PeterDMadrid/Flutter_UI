import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/screens/practice/widgets/choice_card.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  OverlayEntry? _overlayEntry;

  final String instructions = """1. Look at the number word on the screen (like "Three").

2. Find the matching hand sign for the number word in the pictures.

3. Tap the hand sign that matches the number word!""";

  int randomNumber = 0;
  late List<int> choices;

  @override
  void initState() {
    super.initState();
    _generateRandomNumberAndChoices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  void _generateRandomNumberAndChoices() {
    setState(() {
      randomNumber = Random().nextInt(10); // Generate random number (0-9)

      // Generate 3 unique incorrect numbers
      final random = Random();
      final incorrectNumbers = <int>{};
      while (incorrectNumbers.length < 3) {
        int randomChoice = random.nextInt(10);
        if (randomChoice != randomNumber) {
          incorrectNumbers.add(randomChoice);
        }
      }

      // Add the correct answer and shuffle
      choices = [randomNumber, ...incorrectNumbers].toList();
      choices.shuffle();
    });
  }

  void _showInstructions() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Instructions(
        onGotIt: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        instructionContent: instructions,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _checkAnswer(int selectedChoice) {
    if (selectedChoice == randomNumber) {
      print('Correct choice: $selectedChoice');
    } else {
      print('Incorrect choice: $selectedChoice');
    }
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
          Center(
            child: Text(
              randomNumber.toString(), // Display the random number
              style: const TextStyle(fontSize: 50),
            ),
          ),
          GridView.count(
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            crossAxisCount: 2,
            childAspectRatio: 1,
            padding: const EdgeInsets.all(60.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: choices.map((choice) {
              return ChoiceCard(
                choice: choice.toString(),
                onPressed: () => _checkAnswer(choice), // Pass the logic here
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
