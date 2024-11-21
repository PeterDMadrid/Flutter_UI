import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.signImage});

  final String signImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Image.asset(signImage),
        iconSize: 50,
        onPressed: () {},
        splashColor: Colors.transparent, 
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent, 
      )
    );
  }
}
