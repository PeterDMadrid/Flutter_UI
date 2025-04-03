import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/user_session.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final UserSession _userSession = UserSession();

  @override
  void initState() {
    super.initState();
    // If using ChangeNotifier, you would add a listener here
    _userSession.addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    _userSession.removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) setState(() {});
  }

  Widget _buildUserHeader(bool isDarkMode) {
    if (_userSession.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppStyles.getTextColor(isDarkMode),
          backgroundImage: _userSession.profilePicture != null
              ? NetworkImage(_userSession.profilePicture!)
              : null,
          child: _userSession.profilePicture == null
              ? Icon(
                  Icons.account_circle,
                  size: 60,
                  color: AppStyles.getBackgroundColor(isDarkMode),
                )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          _userSession.username,
          style: AppStyles.getParagraph1(isDarkMode),
        ),
        Text(
          "Level ${_userSession.currentLevel}",
          style: AppStyles.getParagraph2(isDarkMode),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager().isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Drawer(
          child: Container(
            color: AppStyles.getBackgroundColor(isDarkMode),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppStyles.getBackgroundColor(isDarkMode),
                  ),
                  child: _buildUserHeader(isDarkMode),
                ),
                // Theme Toggle
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: AppStyles.getTextColor(isDarkMode),
                  ),
                  title: Text(
                    'Toggle Theme',
                    style: AppStyles.getParagraph2(isDarkMode),
                  ),
                  onTap: () {
                    ThemeManager().toggleTheme();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout,
                      color: AppStyles.getTextColor(isDarkMode)),
                  title: Text(
                    'Logout',
                    style: AppStyles.getParagraph2(isDarkMode),
                  ),
                  onTap: () {
                    _userSession.logoutUser(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
