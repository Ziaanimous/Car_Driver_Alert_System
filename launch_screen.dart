import 'package:flutter/material.dart';
import 'login_signup.dart';
import '../mainnavigation.dart';
import 'logic/auth_logic.dart';
import 'package:camera/camera.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  late Future<List<CameraDescription>> _camerasFuture;

  @override
  void initState() {
    super.initState();
    _camerasFuture = availableCameras();
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
              // Animated logo
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.hexagon_outlined, 
                            size: 126 * value, 
                            color: Color.fromRGBO(1, 138, 189, value)),
                        Icon(Icons.hexagon_outlined, 
                            size: 118 * value, 
                            color: Color.fromRGBO(1, 138, 189, value)),
                        Icon(Icons.hexagon_outlined, 
                            size: 85 * value, 
                            color: Color.fromRGBO(255, 255, 255, value)),
                        Icon(Icons.hexagon, 
                            size: 50 * value, 
                            color: Color.fromRGBO(0, 91, 136, value)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Car Driver Alert',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Stay awake, stay safe.\nYour ultimate driving companion.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
              
              // Show loading indicator while checking auth state and cameras
              FutureBuilder<List<CameraDescription>>(
                future: _camerasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Color(0xFF018ABD),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final cameras = snapshot.data!;
                    return _buildContinueButton(cameras);
                  } else {
                    return const Text('No cameras available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(List<CameraDescription> cameras) {
    return SizedBox(
      width: 160,
      height: 45,
      child: ElevatedButton(
        onPressed: () async {
          if (!mounted) return;
          
          final BuildContext currentContext = context;
          
          // Check if user is already logged in
          final authLogic = AuthLogic();
          await authLogic.initialize();
          
          if (!mounted) return;
          
          if (authLogic.isLoggedIn) {
            // Navigate to main app
            Navigator.pushReplacement(
              currentContext,
              MaterialPageRoute(
                builder: (_) => MainNavigation(
                  username: authLogic.username,
                  cameras: cameras,
                ),
              ),
            );
          } else {
            // Navigate to login/signup
            Navigator.pushReplacement(
              currentContext,
              MaterialPageRoute(
                builder: (_) => const LoginSignupScreen(),
              ),
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
    );
  }
}
