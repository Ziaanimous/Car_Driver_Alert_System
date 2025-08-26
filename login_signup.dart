import 'package:flutter/material.dart';
import 'welcome.dart';
import '../mainnavigation.dart';
import 'logic/auth_logic.dart';
import 'package:camera/camera.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool agreeToTerms = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  
    Future<void> handleGoogleSignIn() async {
      if (!mounted) return;
      
      // Placeholder for Google Sign In
      final BuildContext currentContext = context;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text("Google Sign In functionality will be implemented")),
      );
    }
  
    Future<void> handleLoginSignup() async {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
    try {
      final authLogic = AuthLogic();
      final BuildContext currentContext = context;

      if (isLogin) {
        // Login logic
        final success = await authLogic.login(
          emailController.text.trim(),
          passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          // Get cameras for main navigation
          final cameras = await availableCameras();

          if (!mounted) return;

          // Navigate to main app
          Navigator.pushReplacement(
            currentContext,
            MaterialPageRoute(
              builder:
                  (_) => MainNavigation(
                    username: authLogic.username,
                    cameras: cameras,
                  ),
            ),
          );
        } else {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text("Login failed. Please check your credentials."),
            ),
          );
        }
      } else {
        // Signup logic
        if (!agreeToTerms) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text("Please agree to Terms & Conditions")),
          );
          return;
        }

        final success = await authLogic.register(
          emailController.text.trim(),
          passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          // Get cameras for welcome screen
          final cameras = await availableCameras();

          if (!mounted) return;

          // Navigate to welcome screen for new user
          Navigator.pushReplacement(
            currentContext,
            MaterialPageRoute(
              builder:
                  (_) => WelcomeScreen(
                    username: authLogic.username,
                    isNewUser: true,
                    cameras: cameras,
                  ),
            ),
          );
        } else {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text("Registration failed. Please try again."),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e"))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getUsernameFromEmail(String email) {
    return email.split('@').first.capitalize();
  }

  InputDecoration inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to CDAS',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                Text(
                  isLogin ? 'Welcome Back' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Fill the form to access your account.'
                      : 'Fill the form to create your account.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                if (!isLogin)
                  Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: inputStyle('Username', Icons.person),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                TextField(
                  controller: emailController,
                  decoration: inputStyle('Email', Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: inputStyle('Password', Icons.lock),
                ),

                if (!isLogin)
                  Row(
                    children: [
                      Checkbox(
                        value: agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            agreeToTerms = value!;
                          });
                        },
                      ),
                      const Text('I agree with '),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : handleLoginSignup,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Text(
                              isLogin ? 'Sign In' : 'Get Started',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    isLogin ? 'Or sign in with' : 'Or sign up with',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : handleGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata, color: Colors.black),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.apple, color: Colors.black),
                      label: const Text(
                        'Continue with Apple',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed:
                          isLogin
                              ? () {
                                setState(() {
                                  isLogin = false;
                                  _animController.forward(from: 0);
                                });
                              }
                              : null,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color:
                              isLogin ? Colors.grey : const Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed:
                          isLogin
                              ? null
                              : () {
                                setState(() {
                                  isLogin = true;
                                  _animController.forward(from: 0);
                                });
                              },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color:
                              isLogin ? const Color(0xFF6366F1) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringCasing on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
