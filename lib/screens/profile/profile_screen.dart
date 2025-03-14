import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/widgets/drawer_button_menu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/screens/lesson/widgets/side_menu.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/screens/profile/widgets/indicator_dots.dart';
import 'package:flutter_hands/screens/profile/widgets/heading_profile.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final int level;
  final String? profilePicture;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.level,
    required this.profilePicture,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  static const _storage = FlutterSecureStorage();
  Map<String, dynamic>? _scores;
  bool _isLoading = true;
  String? _error;
  late List<int> challengeScores;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchScores();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchScores();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchScores();
      }
    });
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _fetchScores() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://${GlobalVariables.server}/api/auth/user-scores/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _scores = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load scores';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading scores: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final success = await AuthService.logout();
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/auth_check');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  int getChallengeScore(int level) {
    final challengeScores =
        (_scores?['challenge_scores'] as List<dynamic>?)?.cast<int>() ?? [];
    if (level < challengeScores.length) {
      return challengeScores[level];
    }
    return 0; // Default score if level doesn't exist
  }

  Widget buildProfileImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: widget.profilePicture != null
          ? CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  widget.profilePicture!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppMedia.defaultProfilePhoto,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            )
          : const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(AppMedia.defaultProfilePhoto),
            ),
    );
  }

  Widget buildProgressBar(
      String title, int score, int maxScore, bool isDarkMode) {
    final double progress = score / maxScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    AppStyles.paragraph2.copyWith(fontWeight: FontWeight.bold)),
            Text(
              "$score / $maxScore",
              style: AppStyles.paragraph2,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor:
                isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? AppStyles.myblue : AppStyles.lightMyBlue,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toStringAsFixed(1)}%",
          style: AppStyles.paragraph2.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget buildPracticeCard(bool isDarkMode) {
    if (_scores == null) return const SizedBox.shrink();

    final recognition = _scores?['recognition'] ?? 0;
    final signing = _scores?['signing'] ?? 0;
    final challengeScores =
        (_scores?['challenge_scores'] as List<dynamic>?)?.cast<int>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppStyles.myblue.withOpacity(0.5)
            : AppStyles.myblue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_gymnastics,
                color: AppStyles.lightMyBlue,
              ),
              const SizedBox(width: 8),
              Text(
                "Practice",
                style: AppStyles.paragraph1.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildProgressBar("Recognition", recognition, 10, isDarkMode),
          const SizedBox(height: 16),
          buildProgressBar("Signing", signing, 10, isDarkMode),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Practice Score",
                style: (isDarkMode
                        ? AppStyles.headLineStyle2
                        : AppStyles.lightHeadLineStyle2)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text("${recognition + signing} / 20",
                  style: AppStyles.paragraph2),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (recognition + signing) / 20,
              minHeight: 12,
              backgroundColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppStyles.khaki,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${((recognition + signing) / 20 * 100).toStringAsFixed(1)}%",
            style: AppStyles.paragraph2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

// Add this to your class variables
  PageController additionPageController = PageController();
  PageController subtractionPageController = PageController();
  int currentAdditionPage = 0;
  int currentSubtractionPage = 0;
  Widget buildChallengeCard(bool isDarkMode) {
    if (_scores == null) return const SizedBox.shrink();

    const int totalLevels = 6;

    // Calculate total challenge score
    final challengeScores =
        (_scores?['challenge_scores'] as List<dynamic>?)?.cast<int>() ?? [];
    final totalChallengeScore =
        challengeScores.fold(0, (sum, score) => sum + score);
    // Assuming maximum score is 10 points per level and you have 12 levels total
    const maxChallengeScore = 120; // 12 levels × 10 points

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppStyles.roseRed.withOpacity(0.5)
            : AppStyles.roseRed.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppStyles.khaki,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Challenge Scores",
                style: AppStyles.paragraph1.copyWith(
                  fontSize: 18,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Addition levels
          SizedBox(
            height: 70,
            child: PageView.builder(
              controller: additionPageController,
              itemCount: totalLevels,
              onPageChanged: (index) {
                setState(() {
                  currentAdditionPage = index;
                });
              },
              itemBuilder: (context, index) {
                final levelNumber = index + 1;
                final levelScore = getChallengeScore(levelNumber);

                return buildProgressBar(
                    "Addition: $levelNumber Score", levelScore, 10, isDarkMode);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Indicator dots for Addition
          IndicatorDots(
              currentAdditionPage: currentAdditionPage,
              totalLevels: totalLevels),

          const SizedBox(height: 24),

          // Subtraction levels
          SizedBox(
            height: 70,
            child: PageView.builder(
              controller: subtractionPageController,
              itemCount: totalLevels,
              onPageChanged: (index) {
                setState(() {
                  currentSubtractionPage = index;
                });
              },
              itemBuilder: (context, index) {
                final levelNumber = index + 7;
                final levelScore = getChallengeScore(levelNumber);

                return buildProgressBar("Subtraction: $levelNumber Score",
                    levelScore, 10, isDarkMode);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Indicator dots for Subtraction
          IndicatorDots(
              currentAdditionPage: currentSubtractionPage,
              totalLevels: totalLevels),

          // Add divider and total section
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Total Challenge Score section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Challenge",
                style: (isDarkMode
                        ? AppStyles.headLineStyle2
                        : AppStyles.lightHeadLineStyle2)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text("$totalChallengeScore / $maxChallengeScore",
                  style: AppStyles.paragraph2),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalChallengeScore / maxChallengeScore,
              minHeight: 12,
              backgroundColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppStyles.khaki,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(totalChallengeScore / maxChallengeScore * 100).toStringAsFixed(1)}%",
            style: AppStyles.paragraph2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager().isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
          endDrawer: const SideMenu(),
          body: Stack(
            children: [
              _buildProfileContent(isDarkMode),
              const DrawerButtonMenu()
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(bool isDarkMode) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              buildProfileImage(),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: isDarkMode
                    ? AppStyles.headLineStyle1
                    : AppStyles.lightHeadLineStyle1,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppStyles.khaki.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Level ${widget.level}",
                  style: (isDarkMode
                          ? AppStyles.headLineStyle1
                          : AppStyles.lightHeadLineStyle1)
                      .copyWith(
                    fontSize: 20,
                    color: AppStyles.khaki,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Text(
                    _error!,
                    style: isDarkMode
                        ? AppStyles.paragraph1
                        : AppStyles.lightParagraph1,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingProfile(
                        headingText: "Scores", isDarkMode: isDarkMode),
                    buildPracticeCard(isDarkMode),
                    buildChallengeCard(isDarkMode),
                    const SizedBox(height: 16),
                    HeadingProfile(
                        headingText: "Overall", isDarkMode: isDarkMode),
                    buildOverallProgressCard(isDarkMode),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOverallProgressCard(bool isDarkMode) {
    if (_scores == null) return const SizedBox.shrink();

    final recognition = _scores?['recognition'] ?? 0;
    final signing = _scores?['signing'] ?? 0;
    final challengeScores =
        (_scores?['challenge_scores'] as List<dynamic>?)?.cast<int>() ?? [];
    final challenge = challengeScores.fold(0, (sum, score) => sum + score);
    final total = recognition + signing + challenge;
    const maxTotal = 140;
    final progress = total / maxTotal;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    AppStyles.myblue.withOpacity(0.3),
                    AppStyles.myblue.withOpacity(0.1),
                  ]
                : [
                    AppStyles.lightMyBlue.withOpacity(0.3),
                    AppStyles.lightMyBlue.withOpacity(0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Total Scores",
              style: isDarkMode
                  ? AppStyles.headLineStyle2
                  : AppStyles.lightHeadLineStyle2,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppStyles.khaki,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "${(progress * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppStyles.headlineColor
                            : AppStyles.lightHeadlineColor,
                      ),
                    ),
                    Text(
                      "$total / $maxTotal",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppStyles.textColor
                            : AppStyles.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
