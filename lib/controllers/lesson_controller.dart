import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';
// lesson_state.dart
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

  LessonState copyWith({
    int? currentNumber,
    int? currentTextIndex,
    bool? showContinue,
    bool? showGif,
    List<IntroText>? currentTexts,
  }) {
    return LessonState(
      currentNumber: currentNumber ?? this.currentNumber,
      currentTextIndex: currentTextIndex ?? this.currentTextIndex,
      showContinue: showContinue ?? this.showContinue,
      showGif: showGif ?? this.showGif,
      currentTexts: currentTexts ?? this.currentTexts,
    );
  }
}

// lesson_controller.dart
class LessonController {
  final Function(VoidCallback) setState;
  final List<List<IntroText>> numberSequences;
  final VoidCallback? onLastContinueTapped;
  final VoidCallback? goBackToLessonScreen;
  late final LessonState state;

  LessonController({
    required this.setState,
    required this.numberSequences,
    this.onLastContinueTapped,
    this.goBackToLessonScreen,
  }) {
    state = LessonState(currentTexts: numberSequences[0]);
  }

  void _updateState(LessonState newState) {
    setState(() {
      state.currentNumber = newState.currentNumber;
      state.currentTextIndex = newState.currentTextIndex;
      state.showContinue = newState.showContinue;
      state.showGif = newState.showGif;
      state.currentTexts = newState.currentTexts;
    });
  }

  bool get _isLastText => state.currentTextIndex == state.currentTexts.length - 1;
  bool get _isLastSequence => state.currentNumber == numberSequences.length;

  void _advanceText() {
    if (!_isLastText) {
      _updateState(state.copyWith(
        currentTextIndex: state.currentTextIndex + 1,
        showContinue: false,
      ));
    }
  }

  void _showGif() {
    _updateState(state.copyWith(
      showGif: true,
      showContinue: false,
    ));
  }

  void _nextSequence() {
    _updateState(state.copyWith(
      currentNumber: state.currentNumber + 1,
      currentTexts: numberSequences[state.currentNumber],
      currentTextIndex: 0,
      showGif: false,
      showContinue: false,
    ));
    onLastContinueTapped?.call();
  }

  void _resetToBeginning() {
    _updateState(state.copyWith(
      currentTextIndex: 0,
      currentNumber: 1,
      showContinue: false,
      showGif: false,
      currentTexts: numberSequences[0].sublist(2),
    ));
    onLastContinueTapped?.call();
    goBackToLessonScreen?.call();
  }

  void handleTap() {
    if (!state.showContinue) return;

    if (!_isLastText) {
      _advanceText();
    } else if (!state.showGif) {
      _showGif();
    } else if (!_isLastSequence) {
      _nextSequence();
    } else {
      //_resetToBeginning();
    }
  }

  void handleNumberSelection(int number) {
    _updateState(state.copyWith(
      currentNumber: number + 1,
      currentTextIndex: 0,
      showGif: false,
      showContinue: false,
      currentTexts: numberSequences[number].sublist(1),
    ));
  }
}