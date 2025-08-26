import 'package:flutter/material.dart';

class BluetoothTutorialScreen extends StatelessWidget {
  const BluetoothTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection Tutorial'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Connect to Bluetooth',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Follow these steps to connect your device:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Step 1
            _buildStep(
              step: 1,
              title: 'Enable Bluetooth',
              description: 'Make sure Bluetooth is turned on in your device settings.',
              icon: Icons.bluetooth,
            ),
            
            const SizedBox(height: 20),
            
            // Step 2
            _buildStep(
              step: 2,
              title: 'Pair Your Device',
              description: 'Go to your phone\'s Bluetooth settings and pair with your external alert device.',
              icon: Icons.bluetooth_searching,
            ),
            
            const SizedBox(height: 20),
            
            // Step 3
            _buildStep(
              step: 3,
              title: 'Connect in the App',
              description: 'Return to the app and go to Bluetooth Settings to connect to your paired device.',
              icon: Icons.bluetooth_connected,
            ),
            
            const SizedBox(height: 20),
            
            // Step 4
            _buildStep(
              step: 4,
              title: 'Test the Connection',
              description: 'Once connected, test the connection by triggering an alert to ensure your device responds.',
              icon: Icons.check_circle,
            ),
            
            const SizedBox(height: 30),
            
            // Tips section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF018ABD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• Keep your Bluetooth device charged for optimal performance',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '• If connection issues occur, try turning Bluetooth off and on again',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '• Ensure your external alert device is within range (usually 10 meters)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Done button
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF018ABD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
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
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
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
              const SizedBox(height: 5),
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
    );
  }
}