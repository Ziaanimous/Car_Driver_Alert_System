// settings_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sub_screens/about.dart';
import 'sub_screens/tutorial.dart';
import 'sub_screens/feedback.dart';
import 'sub_screens/account.dart';
import 'launch_screen.dart';
import 'logic/auth_logic.dart';

class SettingsScreen extends StatelessWidget {
  final String username;

  const SettingsScreen({super.key, required this.username});

  /// Centered colored button using Material + InkWell to guarantee background color.
  Widget buildButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    double maxWidthCap = 360,
    Color color = const Color(0xFF018ABD),
  }) {
    // responsive width: 85% of screen width, capped at maxWidthCap
    final double width = math.min(
      maxWidthCap,
      MediaQuery.of(context).size.width * 0.85,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: width,
              height: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // icon + title centered
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // open account screen helper
  void _openAccount(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => AccountScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with transparent background and bold title text
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE HEADER (transparent background)
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar - clickable
                  GestureDetector(
                    onTap: () => _openAccount(context),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF018ABD),
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name + subtitle (takes remaining space)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _openAccount(context),
                          child: Text(
                            'Hello, $username 👋',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Drive safely.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Manage Profile button — navigates to AccountScreen
                  OutlinedButton.icon(
                    icon: const Icon(
                      Icons.manage_accounts,
                      size: 18,
                      color: Color(0xFF018ABD),
                    ),
                    label: const Text(
                      'Manage',
                      style: TextStyle(color: Color(0xFF018ABD)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF018ABD)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 0),
                    ),
                    onPressed: () => _openAccount(context),
                  ),
                ],
              ),
            ),

            // SHORTER COLORED BUTTONS (icon + title centered; subtitle below)
            buildButton(
              context,
              icon: Icons.info,
              title: 'About',
              subtitle: 'Learn more about this app',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => AboutScreen()),
                );
              },
            ),
            buildButton(
              context,
              icon: Icons.menu_book,
              title: 'Tutorial',
              subtitle: 'Step-by-step usage guide',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => TutorialScreen()),
                );
              },
            ),
            buildButton(
              context,
              icon: Icons.feedback,
              title: 'Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => FeedbackScreen()),
                );
              },
            ),
            
            // New settings options
            buildButton(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage alert preferences',
              onTap: () {
                // Navigate to notifications settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications settings coming soon')),
                );
              },
            ),
            
            buildButton(
              context,
              icon: Icons.security,
              title: 'Privacy',
              subtitle: 'Manage your privacy settings',
              onTap: () {
                // Navigate to privacy settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon')),
                );
              },
            ),

            // logout uses same visual style but different action
            buildButton(
              context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: Colors.redAccent,
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (d) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(d).pop();
                              // Use auth logic to logout
                              AuthLogic().logout();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => LaunchScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
