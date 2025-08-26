import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'unified_face_detection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../widget/pip_overlay.dart';
import 'data_logic.dart';

class HomeLogic {
  CameraController? cameraController;
  bool _scanning = false;
  bool _isDetecting = false;
  bool _isEyesClosed = false;
  bool _isAlarmActive = false;
  bool _isBluetoothConnected = false;
  BluetoothDevice? _bluetoothDevice;

  Timer? _eyesClosedTimer;
  final int _eyesClosedThresholdMs = 1500;

  BluetoothCharacteristic? _bluetoothCharacteristic;

  double containerWidth = 0;
  double containerHeight = 0;

  late final AudioPlayer _audioPlayer;
  final DataLogic _dataLogic = DataLogic();

  Function(String)? onStatus;
  Function(Map<String, Rect>)? onBoxes;
  Function(bool)? onAlarmStateChanged;

  HomeLogic() {
    _audioPlayer = AudioPlayer();
    PipOverlayManager.initialize();
  }

  void setContainerSize(double width, double height) {
    containerWidth = width;
    containerHeight = height;
  }

  Future<void> initCamera(List<CameraDescription> cams) async {
    try {
      cameraController = CameraController(
        cams.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first,
        ),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      try {
        await WakelockPlus.enable();
        debugPrint('Wakelock enabled successfully');
      } catch (e) {
        debugPrint('Failed to enable wakelock: $e');
        // Continue with the app even if wakelock fails
      }
      await _initBluetooth();
    } catch (e) {
      onStatus?.call('Camera initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _initBluetooth() async {
    try {
      // Check if Bluetooth is available and enabled
      if (await FlutterBluePlus.isSupported == false) {
        onStatus?.call('Bluetooth not available');
        return;
      }
      
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        onStatus?.call('Bluetooth disabled. Enable for external alarm.');
        return;
      }

      // Get connected devices
      List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;
      if (devices.isEmpty) {
        onStatus?.call('No connected Bluetooth devices found');
        // Try to scan for devices if none are connected
        await _scanForDevices();
        return;
      }

      // Use the first connected device
      _bluetoothDevice = devices.first;
      
      // Set up connection state listener
      _bluetoothDevice!.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isBluetoothConnected = false;
          onStatus?.call('Bluetooth device disconnected');
        } else if (state == BluetoothConnectionState.connected) {
          _isBluetoothConnected = true;
          onStatus?.call('Bluetooth device connected');
        }
      });
      
      // Discover services
      List<BluetoothService> services = await _bluetoothDevice!.discoverServices();
      
      // Find the characteristic we need (you may need to adjust the UUIDs)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Replace with the actual UUID of your Bluetooth device's characteristic
          // This is just an example UUID
          if (characteristic.uuid.toString().toUpperCase() == '0000FFE1-0000-1000-8000-00805F9B34FB') {
            _bluetoothCharacteristic = characteristic;
            break;
          }
        }
        if (_bluetoothCharacteristic != null) break;
      }
      
      if (_bluetoothCharacteristic != null) {
        _isBluetoothConnected = true;
        final String deviceName = _bluetoothDevice!.platformName ?? _bluetoothDevice!.remoteId.str;
        onStatus?.call('Connected to $deviceName');
      } else {
        onStatus?.call('Could not find required Bluetooth characteristic');
      }
    } catch (e) {
      onStatus?.call('Bluetooth error: $e');
    }
  }
  
  /// Scan for Bluetooth devices
  Future<void> _scanForDevices() async {
    try {
      onStatus?.call('Scanning for Bluetooth devices...');
      
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          // Look for devices with specific names or service UUIDs
          // You can adjust this to match your specific Bluetooth device
          final deviceName = result.device.platformName ?? '';
          if (deviceName.contains('CDAS') || 
              deviceName.contains('DriverAlert')) {
            // Connect to the first matching device
            _connectToDevice(result.device);
            // Stop scanning after finding a device
            FlutterBluePlus.stopScan();
            break;
          }
        }
      });
      
      // Listen for scan timeout
      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning) {
          onStatus?.call('Bluetooth scan completed');
        }
      });
    } catch (e) {
      onStatus?.call('Bluetooth scan error: $e');
    }
  }
  
  /// Connect to a Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      final String deviceName = device.platformName ?? device.remoteId.str;
      onStatus?.call('Connecting to $deviceName...');
      
      // Connect to the device
      await device.connect();
      
      // Set the device and discover services
      _bluetoothDevice = device;
      _isBluetoothConnected = true;
      
      // Set up connection state listener
      _bluetoothDevice!.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isBluetoothConnected = false;
          onStatus?.call('Bluetooth device disconnected');
        } else if (state == BluetoothConnectionState.connected) {
          _isBluetoothConnected = true;
          onStatus?.call('Bluetooth device connected');
        }
      });
      
      // Discover services
      List<BluetoothService> services = await _bluetoothDevice!.discoverServices();
      
      // Find the characteristic we need (you may need to adjust the UUIDs)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Replace with the actual UUID of your Bluetooth device's characteristic
          // This is just an example UUID
          if (characteristic.uuid.toString().toUpperCase() == '0000FFE1-0000-1000-8000-00805F9B34FB') {
            _bluetoothCharacteristic = characteristic;
            break;
          }
        }
        if (_bluetoothCharacteristic != null) break;
      }
      
      if (_bluetoothCharacteristic != null) {
        final String deviceName = _bluetoothDevice!.platformName ?? _bluetoothDevice!.remoteId.str;
        onStatus?.call('Connected to $deviceName');
      } else {
        onStatus?.call('Could not find required Bluetooth characteristic');
      }
    } catch (e) {
      onStatus?.call('Bluetooth connection error: $e');
    }
  }

  Future<void> startScan() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      onStatus?.call('Camera not ready');
      return;
    }

    _scanning = true;
    onStatus?.call('Face detection active...');

    // Initialize face detection (will automatically use the appropriate method for web/mobile)
    bool faceDetectionInitialized = await UnifiedFaceDetection.initialize();
    if (!faceDetectionInitialized) {
      onStatus?.call('Failed to initialize face detection');
      return;
    }

    // Initialize data logic
    await _dataLogic.loadData();

    cameraController!.startImageStream((CameraImage img) async {
      if (!_scanning || _isDetecting) return;
      _isDetecting = true;

      try {
        // Use unified face detection for both web and mobile
        final result = await UnifiedFaceDetection.processFrame(
          img,
          cameraController!.description,
        );

        if (!result.faceDetected) {
          onStatus?.call('No face detected');
          onBoxes?.call({});
          _isDetecting = false;
          return;
        }

        // Handle drowsiness detection
        if (result.leftEyeClosed && result.rightEyeClosed) {
          if (!_isEyesClosed) {
            _isEyesClosed = true;
            _eyesClosedTimer?.cancel();
            _eyesClosedTimer = Timer(
              Duration(milliseconds: _eyesClosedThresholdMs),
              _triggerAlarm,
            );
          }
          onStatus?.call('Drowsiness detected - Wake up!');
        } else {
          if (_isEyesClosed) {
            _isEyesClosed = false;
            _eyesClosedTimer?.cancel();
            if (_isAlarmActive) _stopAlarm();
          }
        }

        // Handle yawning detection
        if (result.mouthOpen) {
          onStatus?.call('Yawning detected - Take a break!');
        }

        onStatus?.call('Face detected - Monitoring...');

        // Pass bounding boxes to UI
        onBoxes?.call(result.boundingBoxes);
      } catch (e) {
        onStatus?.call('Error: $e');
        onBoxes?.call({});
      } finally {
        _isDetecting = false;
      }
    });
  }

  void stopScan() {
    _scanning = false;
    cameraController?.stopImageStream();
    _stopAlarm();
    // Disable wakelock when stopping scan
    try {
      WakelockPlus.disable();
      debugPrint('Wakelock disabled successfully when stopping scan');
    } catch (e) {
      debugPrint('Failed to disable wakelock when stopping scan: $e');
    }
    onStatus?.call('Scan stopped');
  }

  void _triggerAlarm() {
    if (_isAlarmActive) return;
    _isAlarmActive = true;
    onAlarmStateChanged?.call(true);

    try {
      _audioPlayer.setSource(AssetSource('sounds/alarm.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.resume();

      // Increment high alarms in data logic
      _dataLogic.incrementHighAlarms();
    } catch (e) {
      debugPrint('Audio player error: $e');
      // Try to play a fallback sound or system sound
      try {
        HapticFeedback.heavyImpact();
      } catch (hapticError) {
        debugPrint('Haptic feedback error: $hapticError');
      }
    }

    // Add haptic feedback
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
    
    // Add periodic haptic feedback while alarm is active
    Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!_isAlarmActive) {
        t.cancel();
      } else {
        try {
          HapticFeedback.heavyImpact();
        } catch (e) {
          debugPrint('Periodic haptic feedback error: $e');
        }
      }
    });

    // Send Bluetooth alert if connected
    if (_isBluetoothConnected && _bluetoothCharacteristic != null) {
      try {
        _bluetoothCharacteristic!.write(Uint8List.fromList([1]), withoutResponse: true);
      } catch (e) {
        debugPrint('Bluetooth send error: $e');
      }
    }

    // Show PIP overlay alert
    try {
      PipOverlayManager.showDrowsinessAlert();
    } catch (e) {
      debugPrint('PIP overlay error: $e');
    }
  }

  void _stopAlarm() {
    if (!_isAlarmActive) return;
    _isAlarmActive = false;
    onAlarmStateChanged?.call(false);

    // Stop audio playback
    try {
      _audioPlayer.pause();
    } catch (e) {
      debugPrint('Audio player error: $e');
    }

    // Send Bluetooth stop alert if connected
    if (_isBluetoothConnected && _bluetoothCharacteristic != null) {
      try {
        _bluetoothCharacteristic!.write(Uint8List.fromList([0]), withoutResponse: true);
      } catch (e) {
        debugPrint('Bluetooth send error: $e');
      }
    }

    // Hide PIP overlay
    try {
      PipOverlayManager.hideOverlay();
    } catch (e) {
      debugPrint('PIP overlay hide error: $e');
    }
  }
  
  void dispose() {
    cameraController?.dispose();
    _audioPlayer.dispose();
    _eyesClosedTimer?.cancel();
    // Bluetooth connection is managed by FlutterBluePlus, no explicit close needed
    try {
      WakelockPlus.disable();
      debugPrint('Wakelock disabled successfully in dispose');
    } catch (e) {
      debugPrint('Failed to disable wakelock in dispose: $e');
    }
    PipOverlayManager.dispose();
  }

  // Getter to check if Bluetooth is connected
  bool get isBluetoothConnected => _isBluetoothConnected;
}
