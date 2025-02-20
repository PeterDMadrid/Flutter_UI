import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_hands/base/res/global/global_variables.dart';

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

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  static const _storage = FlutterSecureStorage();
  Map<String, dynamic>? _scores;
  bool _isLoading = true;
  String? _error;

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

  // Add this method to handle navigation focus
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up a focus node to detect when the screen gains focus
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

  Widget buildProfileImage() {
    if (widget.profilePicture != null) {
      return CircleAvatar(
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
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(AppMedia.defaultProfilePhoto),
      );
    }
  }

  Widget buildScoresTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _fetchScores,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final recognition = _scores?['recognition'] ?? 0;
    final signing = _scores?['signing'] ?? 0;
    final totalProgress = ((recognition + signing) / 200 * 100).toStringAsFixed(1);

    return Table(
      border: const TableBorder(
        top: BorderSide(color: Colors.white),
        bottom: BorderSide(color: Colors.white),
        left: BorderSide(color: Colors.white),
        right: BorderSide(color: Colors.white),
        horizontalInside: BorderSide(color: Colors.white),
        verticalInside: BorderSide(color: Colors.white),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Quiz',
                  style: AppStyles.headLineStyle2.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Scores',
                  style: AppStyles.headLineStyle2.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recognition Practice',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recognition.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Signing Practice',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  signing.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Total Progress', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$totalProgress%',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: AppStyles.backgroundColor),
          height: screenHeight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      buildProfileImage(),
                      const SizedBox(height: 16),
                      Text(
                        widget.name,
                        style: AppStyles.headLineStyle1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Level ${widget.level}",
                        style: AppStyles.headLineStyle1.copyWith(
                          fontSize: 24,
                          color: AppStyles.khaki,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildScoresTable(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Implement edit functionality here
                      } else if (value == 'logout') {
                        logoutUser(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                       return [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text('Edit Profile', style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text('Logout', style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
