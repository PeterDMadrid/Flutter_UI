import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class DrawerButtonMenu extends StatelessWidget {
  const DrawerButtonMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.menu, color:isDarkMode ? Colors.white70 : Colors.black87),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          );
        });
  }
}
