import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class ProfileSelection extends StatelessWidget {
  final double profileImageSize;
  final double gridSpacing;
  final double fontSize;
  final List<Map<String, dynamic>> savedProfiles;
  final Function(Map<String, dynamic>) onProfileSelect;
  final VoidCallback onAddProfileTap;

  const ProfileSelection({
    super.key,
    required this.profileImageSize,
    required this.gridSpacing,
    required this.fontSize,
    required this.savedProfiles,
    required this.onProfileSelect,
    required this.onAddProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: gridSpacing,
            crossAxisSpacing: gridSpacing,
            childAspectRatio: 0.85,
            children: [
              ...savedProfiles.map((profile) => GestureDetector(
                onTap: () => onProfileSelect(profile),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: profileImageSize,
                      height: profileImageSize,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black87,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            'http://127.0.0.1:8000/media/profile${profile['profilePictureId']}.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: profileImageSize * 0.8,
                                color: Colors.black87,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile['username'],
                      style: AppStyles.darkTextStyle.copyWith(fontSize: fontSize),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )),
              if (savedProfiles.length < 5)
                GestureDetector(
                  onTap: onAddProfileTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: profileImageSize,
                        height: profileImageSize,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black87,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: profileImageSize * 0.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Profile',
                        style: AppStyles.darkTextStyle.copyWith(fontSize: fontSize)
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
