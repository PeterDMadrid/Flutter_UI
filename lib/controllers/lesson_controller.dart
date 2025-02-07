import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';

class LessonState {
  int currentNumber;
  int currentTextIndex;
  bool showContinue;
  bool showGif;
  List<IntroText> currentTexts;

  LessonState({
    this.currentNumber = 1,
    this.currentTextIndex = 0,
    this.showContinue = false,
    this.showGif = false,
    required this.currentTexts,
  });
}

class LessonController {
  final Function(VoidCallback) setState;
  final List<List<IntroText>> numberSequences;
  final VoidCallback? onLastContinueTapped;
  late final LessonState state;

  LessonController(
      {required this.setState,
      required this.numberSequences,
      this.onLastContinueTapped}) {
    state = LessonState(
      currentTexts: numberSequences[0],
    );
  }

  void handleTap() {
    if (!state.showContinue) return;
    setState(() {
      if (state.currentTextIndex < state.currentTexts.length - 1) {
        state.currentTextIndex++;
        state.showContinue = false;
      } else if (!state.showGif) {
        state.showGif = true;
        state.showContinue = false;
      } else {
        if (state.currentNumber < numberSequences.length) {
          state.currentNumber++;
          state.currentTexts = numberSequences[state.currentNumber - 1];
          state.currentTextIndex = 0;
          state.showGif = false;
          state.showContinue = false;
        } else if (state.currentNumber == numberSequences.length) {
          state.currentTextIndex = 0;
          state.currentNumber = 1;
          state.showContinue = false;
          state.showGif = false;
          state.currentTexts = numberSequences[0].sublist(2);
          if (onLastContinueTapped != null) {
            onLastContinueTapped!();
          }
        }
      }
    });
  }

  void handleNumberSelection(int number) {
    setState(() {
      state.currentNumber = number + 1;
      state.currentTextIndex = 0;
      state.showGif = false;
      state.showContinue = false;
      state.currentTexts = numberSequences[number].sublist(1);
    });
  }
}
