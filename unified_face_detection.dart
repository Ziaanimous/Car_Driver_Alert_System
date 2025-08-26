import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:camera/camera.dart';

// Always import the mobile implementation
import 'mobile_face_detection_mobile.dart' as mobile;

// Import TensorFlow Lite implementation
import 'tensorflow_face_detection.dart' as tf;

/// Unified face detection interface for mobile using TensorFlow Lite and Google ML Kit
class UnifiedFaceDetection {
  static bool _initialized = false;
  static bool _useTfLite = false;

  /// Initialize face detection with TensorFlow Lite and Google ML Kit
  static Future<bool> initialize({bool useTfLite = false}) async {
    if (_initialized) return true;

    _useTfLite = useTfLite;

    try {
      if (_useTfLite) {
        // Initialize TensorFlow Lite face detection (mobile only)
        bool result = await tf.TensorflowFaceDetection.initialize();
        _initialized = result;
      } else {
        // Initialize Google ML Kit face detection (mobile only)
        bool result = await mobile.MobileFaceDetection.initialize();
        _initialized = result;
      }

      debugPrint(
        'Unified face detection initialized with ${_useTfLite ? "TensorFlow Lite" : "Google ML Kit"}: $_initialized',
      );
      return _initialized;
    } catch (e) {
      debugPrint('Error initializing face detection: $e');
      return false;
    }
  }

  /// Process a single frame for face detection
  static Future<mobile.FaceDetectionResult> processFrame(
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    if (!_initialized) {
      return mobile.FaceDetectionResult(
        faceDetected: false,
        leftEyeClosed: false,
        rightEyeClosed: false,
        mouthOpen: false,
        boundingBoxes: {},
      );
    }

    try {
      if (_useTfLite) {
        // Use TensorFlow Lite for face detection (mobile only)
        return await tf.TensorflowFaceDetection.processFrame(
          image,
          cameraDescription,
        );
      } else {
        // Use Google ML Kit for face detection (mobile only)
        Completer<mobile.FaceDetectionResult> completer =
            Completer<mobile.FaceDetectionResult>();

        void onResultCallback(mobile.FaceDetectionResult result) {
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        }

        mobile.MobileFaceDetection.startDetection(
          onResultCallback,
          image,
          cameraDescription,
        );

        try {
          return await completer.future.timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('Timeout or error waiting for face detection result: $e');
          return mobile.FaceDetectionResult(
            faceDetected: false,
            leftEyeClosed: false,
            rightEyeClosed: false,
            mouthOpen: false,
            boundingBoxes: {},
          );
        }
      }
    } catch (e) {
      debugPrint('Error processing frame: $e');
      return mobile.FaceDetectionResult(
        faceDetected: false,
        leftEyeClosed: false,
        rightEyeClosed: false,
        mouthOpen: false,
        boundingBoxes: {},
      );
    }
  }

  /// Stop face detection
  static void stopDetection() {
    if (_useTfLite) {
      // No explicit stop for TensorFlow Lite
    } else {
      mobile.MobileFaceDetection.stopDetection();
    }
    debugPrint('Face detection stopped');
  }

  /// Dispose resources
  static void dispose() {
    stopDetection();
    if (_useTfLite) {
      tf.TensorflowFaceDetection.dispose();
    } else {
      mobile.MobileFaceDetection.dispose();
    }
    _initialized = false;
    debugPrint('Face detection disposed');
  }

  /// Check if face detection is supported on this platform
  static bool isSupported() {
    return true; // mobile only
  }
}
