import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/user_session.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppStyles.getTextColor(isDarkMode),
                        backgroundImage: UserSession().profilePicture != null
                            ? NetworkImage(UserSession().profilePicture!)
                            : null,
                        child: UserSession().profilePicture == null
                            ? Icon(
                                Icons.account_circle,
                                size: 60,
                                color: AppStyles.getTextColor(isDarkMode),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        UserSession().username,
                        style: AppStyles.getParagraph1(isDarkMode),
                      ),
                      Text(
                        "Level ${UserSession().currentLevel}",
                        style: AppStyles.getParagraph2(isDarkMode),
                      ),
                    ],
                  ),
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
                    UserSession().logoutUser(context);
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
