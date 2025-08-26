import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'logic/home_logic.dart';
import 'logic/camera_service.dart';
import '../widget/bluetooth_notification_card.dart';
import 'sub_screens/bluetooth_settings.dart';
import 'sub_screens/bluetooth_tutorial.dart';
// import '../widget/camera.dart'; // Removed CameraWidget import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeLogic _logic = HomeLogic();
  
  String _status = '';
  Map<String, Rect>? _boxes;
  bool _scanning = false;
  bool _isAlarmActive = false;
  bool _isCameraReady = false;
  bool _showBluetoothNotification = false;

  final double viewfinderWidth = 320;
  final double viewfinderHeight = 200;

  @override
  void initState() {
    super.initState();

    // Listen to camera service updates
    // We'll set up the listeners in the build method using Provider
    
    // Listen for Bluetooth connection changes
    // This is a simplified approach - in a real app, you would need to implement
    // a more robust solution to listen for Bluetooth connection changes
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  void _toggleScan() {
    final cameraService = Provider.of<CameraService>(context, listen: false);
    if (cameraService.isScanning) {
      cameraService.stopScan();
    } else {
      // For now, we'll just start scanning directly
      // In a real app, you would check Bluetooth connection here
      cameraService.startScan();
    }
  }

  void _stopAlarm() {
    final cameraService = Provider.of<CameraService>(context, listen: false);
    cameraService.stopAlarm();
  }

  void _connectToBluetooth() {
    // Navigate to Bluetooth settings screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BluetoothSettingsScreen(),
      ),
    ).then((_) {
      // After returning from Bluetooth settings, check if connected
      if (_logic.isBluetoothConnected) {
        setState(() {
          _showBluetoothNotification = false;
        });
      }
    });
  }

  void _showTutorial() {
    // Navigate to Bluetooth tutorial screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BluetoothTutorialScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraService>(
      builder: (context, cameraService, child) {
        // Update local state with camera service values
        _isCameraReady = cameraService.isCameraReady;
        _scanning = cameraService.isScanning;
        _isAlarmActive = cameraService.isAlarmActive;
        _boxes = cameraService.boxes;
        _status = cameraService.status;
        
        return Scaffold(
          backgroundColor: _isAlarmActive ? Colors.red.shade100 : Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      _isAlarmActive ? Icons.warning_amber_rounded : Icons.visibility,
                      size: 32,
                      color: _isAlarmActive ? Colors.red : const Color(0xFF018ABD),
                    ),
                    const SizedBox(height: 12),
                    if (_isAlarmActive)
                      Text(
                        'WAKE UP!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Spacer(),
                    Center(
                      child: Container(
                        width: viewfinderWidth,
                        height: viewfinderHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAlarmActive ? Colors.red : Colors.black,
                            width: _isAlarmActive ? 4 : 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Camera preview from camera service
                              if (cameraService.cameraController != null &&
                                  cameraService.cameraController!.value.isInitialized)
                                SizedBox(
                                  width: viewfinderWidth,
                                  height: viewfinderHeight,
                                  child: CameraPreview(cameraService.cameraController!),
                                ),
                              if (_boxes != null)
                                CustomPaint(
                                  size: Size(viewfinderWidth, viewfinderHeight),
                                  painter: FaceBoxesPainter(_boxes!),
                                ),
                              if (_isAlarmActive)
                                Container(
                                  width: viewfinderWidth,
                                  height: viewfinderHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'DRIVER ALERT!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: Colors.white.withAlpha(179),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    Text(
                      _isAlarmActive
                          ? 'DRIVER FALLING ASLEEP! WAKE UP!'
                          : (_scanning
                              ? 'Monitoring... Keep your face visible'
                              : 'Press Scan to start monitoring'),
                      style: TextStyle(
                        color: _isAlarmActive ? Colors.red : Colors.black,
                        fontSize: _isAlarmActive ? 18 : 14,
                        fontWeight:
                            _isAlarmActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _isCameraReady ? _toggleScan : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF018ABD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _scanning ? 'Stop' : 'Scan',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        if (_isAlarmActive) ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _stopAlarm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Stop Alarm',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _isAlarmActive ? Colors.red : Colors.black,
                        fontSize: 16,
                        fontWeight:
                            _isAlarmActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                // PIP toggle button in top right corner
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: cameraService.togglePipMode,
                    backgroundColor: cameraService.isPipMode
                        ? const Color(0xFF018ABD)
                        : Colors.white,
                    child: Icon(
                      cameraService.isPipMode
                          ? Icons.picture_in_picture_alt
                          : Icons.picture_in_picture,
                      color: cameraService.isPipMode
                          ? Colors.white
                          : const Color(0xFF018ABD),
                    ),
                  ),
                ),
                // Bluetooth notification card
                if (_showBluetoothNotification)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BluetoothNotificationCard(
                      onConnectPressed: _connectToBluetooth,
                      onTutorialPressed: _showTutorial,
                      onClose: () {
                        setState(() {
                          _showBluetoothNotification = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FaceBoxesPainter extends CustomPainter {
  final Map<String, Rect> boxes;
  FaceBoxesPainter(this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    final paintGreenEye =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final paintRedEye =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final paintMouth =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Draw eyes with appropriate color based on closure status
    if (boxes.containsKey("leftEye")) {
      final isClosed = boxes.containsKey("leftEyeClosed");
      canvas.drawRect(
        boxes["leftEye"]!,
        isClosed ? paintRedEye : paintGreenEye,
      );
    }
    if (boxes.containsKey("rightEye")) {
      final isClosed = boxes.containsKey("rightEyeClosed");
      canvas.drawRect(
        boxes["rightEye"]!,
        isClosed ? paintRedEye : paintGreenEye,
      );
    }
    if (boxes.containsKey("mouth")) {
      final isYawning = boxes.containsKey("mouthOpen");
      Paint paintMouthColor;
      if (isYawning) {
        paintMouthColor =
            Paint()
              ..color = Colors.red
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke;
      } else {
        paintMouthColor = paintMouth;
      }
      canvas.drawRect(boxes["mouth"]!, paintMouthColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

