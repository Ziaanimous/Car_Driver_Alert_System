import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:system_alert_window/system_alert_window.dart';

class CameraService with ChangeNotifier {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _cameraController;
  bool _isScanning = false;
  bool _isCameraReady = false;
  bool _isPipMode = false;
  String _status = '';
  Map<String, Rect>? _boxes;
  bool _isAlarmActive = false;

  // Callbacks
  Function(String)? onStatus;
  Function(Map<String, Rect>)? onBoxes;
  Function(bool)? onAlarmStateChanged;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isScanning => _isScanning;
  bool get isCameraReady => _isCameraReady;
  bool get isPipMode => _isPipMode;
  String get status => _status;
  Map<String, Rect>? get boxes => _boxes;
  bool get isAlarmActive => _isAlarmActive;

  // Initialize camera with provided cameras
  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    try {
      if (cameras.isEmpty) {
        _status = 'No cameras available';
        notifyListeners();
        return;
      }

      // Use the first available camera (usually rear camera)
      final CameraDescription firstCamera = cameras.first;

      // Create the camera controller
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Initialize the controller
      await _cameraController?.initialize();
      
      _isCameraReady = true;
      _status = 'Camera ready';
      notifyListeners();
    } catch (e) {
      _status = 'Camera initialization failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Start scanning
  void startScan() {
    if (!_isCameraReady || _cameraController == null) {
      _status = 'Camera not ready';
      notifyListeners();
      return;
    }

    try {
      // In a real implementation, this would start the face detection logic
      // For now, we'll just set the scanning state
      _isScanning = true;
      _status = 'Scanning...';
      notifyListeners();
      
      // Simulate face detection updates
      // In a real app, this would be replaced with actual face detection logic
      _simulateFaceDetection();
    } catch (e) {
      _status = 'Scan start failed: $e';
      notifyListeners();
    }
  }

  // Stop scanning
  void stopScan() {
    _isScanning = false;
    _status = 'Scan stopped';
    notifyListeners();
  }

  // Toggle PIP mode
  void togglePipMode() {
    _isPipMode = !_isPipMode;
    notifyListeners();
    
    if (_isPipMode) {
      _showPipOverlay();
    } else {
      _hidePipOverlay();
    }
  }

  // Show PIP overlay
  void _showPipOverlay() {
    if (kIsWeb) {
      // PIP not supported on web
      return;
    }

    try {
      // Show a simple PIP overlay with camera preview
      SystemAlertWindow.showSystemWindow(
        notificationTitle: "CDAS Camera",
        notificationBody: "Driver monitoring active",
      );
    } catch (e) {
      debugPrint('Error showing PIP overlay: $e');
    }
  }

  // Hide PIP overlay
  void _hidePipOverlay() {
    if (kIsWeb) {
      return;
    }

    try {
      SystemAlertWindow.closeSystemWindow();
    } catch (e) {
      debugPrint('Error hiding PIP overlay: $e');
    }
  }

  // Simulate face detection for demonstration
  void _simulateFaceDetection() {
    if (!_isScanning) return;

    // This is a placeholder for actual face detection logic
    // In a real implementation, this would process camera frames
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      // Simulate face detection results
      final randomBoxes = <String, Rect>{};
      // Add some dummy face boxes for demonstration
      randomBoxes['face'] = Rect.fromLTWH(50, 50, 100, 100);
      
      _boxes = randomBoxes;
      notifyListeners();
    });
  }

  // Trigger alarm
  void triggerAlarm() {
    _isAlarmActive = true;
    notifyListeners();
    
    // Show alert overlay
    try {
      SystemAlertWindow.showSystemWindow(
        notificationTitle: "⚠️ Driver Alert",
        notificationBody: "Wake up! You appear to be drowsy.\nPlease take a break.",
      );
    } catch (e) {
      debugPrint('Error showing alert: $e');
    }
  }

  // Stop alarm
  void stopAlarm() {
    _isAlarmActive = false;
    notifyListeners();
    
    // Hide alert overlay
    try {
      SystemAlertWindow.closeSystemWindow();
    } catch (e) {
      debugPrint('Error hiding alert: $e');
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _isScanning = false;
    _isPipMode = false;
    _cameraController?.dispose();
    _cameraController = null;
    _hidePipOverlay();
    super.dispose();
    notifyListeners();
  }
}