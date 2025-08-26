import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/launch_screen.dart';
import 'widget/pip_overlay.dart';
import 'screens/logic/auth_logic.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAP_H27miTTi6GIkPM9zgCBBVdmwLSdLBA",
        appId: "1:491774373723:android:e0171ca5e2fd4905fa747e", // check google-services.json for this
        messagingSenderId: "491774373723",
        projectId: "cdas-f23fb",
      ),
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await PipOverlayManager.initialize();
    debugPrint('PIP overlay initialized successfully');
  } catch (e) {
    debugPrint('PIP overlay initialization error: $e');
  }

  try {
    await AuthLogic().initialize();
    debugPrint('Auth logic initialized successfully');
  } catch (e) {
    debugPrint('Auth logic initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Driver Alert System',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF018ABD),
          primary: const Color(0xFF018ABD),
          secondary: const Color(0xFF6366F1),
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF018ABD),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF018ABD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF018ABD)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      home: const LaunchScreen(),
      builder: (context, widget) {
        if (widget == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Application Error: Widget is null',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }
        return ErrorBoundary(child: Scaffold(body: widget));
      },
      navigatorKey: GlobalKey<NavigatorState>(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return const ErrorScreen(message: 'Unknown route encountered');
          },
        );
      },
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 20),
              Text(
                'An error occurred: $message',
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
