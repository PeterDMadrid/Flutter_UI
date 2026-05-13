import 'package:flutter/material.dart';

class ThemeManager {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  
  factory ThemeManager() {
    return _instance;
  }

  ThemeManager._internal();

  // Observable pattern
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

  void toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }

  // Getter for convenient access
  bool get isDarkMode => isDarkModeNotifier.value;
}