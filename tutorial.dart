import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
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
            const Text(
              'How to Use',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Follow these simple steps to get started with the Car Driver Alert System:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Step 1
            _buildTutorialStep(
              1,
              'Launch the App',
              'Open the Car Driver Alert System app on your device.',
              Icons.phone_android,
            ),
            const SizedBox(height: 16),
            
            // Step 2
            _buildTutorialStep(
              2,
              'Sign In or Register',
              'If you\'re a new user, create an account. Existing users can sign in with their credentials.',
              Icons.account_circle,
            ),
            const SizedBox(height: 16),
            
            // Step 3
            _buildTutorialStep(
              3,
              'Grant Permissions',
              'Allow camera access when prompted. This is essential for drowsiness detection.',
              Icons.camera_alt,
            ),
            const SizedBox(height: 16),
            
            // Step 4
            _buildTutorialStep(
              4,
              'Start Monitoring',
              'On the Home screen, tap the "Scan" button to begin monitoring your driving state.',
              Icons.visibility,
            ),
            const SizedBox(height: 16),
            
            // Step 5
            _buildTutorialStep(
              5,
              'Stay Alert',
              'Keep your face visible to the camera. The system will detect signs of drowsiness and alert you.',
              Icons.warning,
            ),
            const SizedBox(height: 16),
            
            // Step 6
            _buildTutorialStep(
              6,
              'View Statistics',
              'Check the Data screen to see your driving statistics and safety scores.',
              Icons.analytics,
            ),
            const SizedBox(height: 16),
            
            // Step 7
            _buildTutorialStep(
              7,
              'Adjust Settings',
              'Customize alerts, notifications, and other preferences in the Settings menu.',
              Icons.settings,
            ),
            const SizedBox(height: 30),
            
            // Tips section
            const Text(
              'Tips for Best Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.lightbulb_outline,
              'Position your device where it can clearly see your face while driving.',
            ),
            _buildTipItem(
              Icons.wb_sunny,
              'Ensure adequate lighting for better camera detection.',
            ),
            _buildTipItem(
              Icons.battery_charging_full,
              'Keep your device charged for uninterrupted monitoring.',
            ),
            _buildTipItem(
              Icons.update,
              'Regularly update the app for the latest features and improvements.',
            ),
            const SizedBox(height: 20),
            
            // Warning section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withAlpha(77)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Important: This app is a辅助驾驶 tool and should not replace safe driving practices. Always stay alert and focused on the road.',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTutorialStep(int step, String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF018ABD),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF018ABD)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF018ABD), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
