import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../mainnavigation.dart';
import 'logic/auth_logic.dart';

class WelcomeScreen extends StatefulWidget {
  final String username;
  final bool isNewUser;
  final List<CameraDescription> cameras;

  const WelcomeScreen({
    super.key,
    required this.username,
    required this.isNewUser,
    required this.cameras,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.celebration,
                  size: 100,
                  color: Color(0xFF018ABD),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.isNewUser
                      ? 'Welcome, ${widget.username}!'
                      : 'Welcome back, ${widget.username}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Thanks for using Car Driver Alert. Let\'s keep your journey safe and alert.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.isNewUser
                      ? 'We\'re excited to have you on board. Get ready to experience safe driving like never before.'
                      : 'We\'re glad to see you again. Your safety is our priority.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!mounted) return;
                      
                      final BuildContext currentContext = context;
                      try {
                        // Update user profile if needed
                        if (widget.isNewUser) {
                          final authLogic = AuthLogic();
                          await authLogic.updateProfile(widget.username);
                        }

                        if (!mounted) return;
                        
                        // Navigate to main app with cameras
                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(
                            builder:
                                (_) => MainNavigation(
                                  username: widget.username,
                                  cameras: widget.cameras,
                                ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(content: Text('Camera error: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF018ABD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
