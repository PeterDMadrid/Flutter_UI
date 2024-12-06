import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.choice, required this.onPressed});

  final String choice;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed, // Use the passed callback
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(24.0),
          minimumSize: const Size(100, 100),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          choice,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
