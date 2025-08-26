import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF018ABD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // App title
            const Center(
              child: Text(
                'Car Driver Alert System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF018ABD),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            
            // App description
            const Text(
              'This app helps drivers stay alert and avoid drowsiness-related accidents using camera technology and real-time alerts.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Features section
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.visibility,
              'Real-time Monitoring',
              'Continuously monitors driver\'s eyes and facial expressions',
            ),
            _buildFeatureItem(
              Icons.warning,
              'Instant Alerts',
              'Provides immediate warnings when drowsiness is detected',
            ),
            _buildFeatureItem(
              Icons.analytics,
              'Driving Analytics',
              'Tracks and analyzes driving patterns for safety improvements',
            ),
            _buildFeatureItem(
              Icons.settings,
              'Customizable Settings',
              'Adjust sensitivity and alert preferences to your needs',
            ),
            const SizedBox(height: 20),
            
            // How it works section
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. The app uses your device\'s front camera to monitor your face.\n'
              '2. Advanced algorithms detect signs of drowsiness like closed eyes or yawning.\n'
              '3. When drowsiness is detected, the app triggers visual and audio alerts.\n'
              '4. Statistics are collected to help you understand your driving patterns.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Developer info
            const Text(
              'Developer Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This application was developed to enhance road safety by preventing '
              'drowsiness-related accidents. Our team is committed to creating '
              'innovative solutions that protect drivers and passengers.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Version info
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            
            // Copyright
            const Center(
              child: Text(
                '© 2023 Car Driver Alert System. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF018ABD), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
