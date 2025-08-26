// Stub implementation for TensorFlow Lite on web (not supported)
import 'package:camera/camera.dart';

// Conditionally import the appropriate face detection implementation for FaceDetectionResult
import 'mobile_face_detection_mobile.dart' if (dart.library.html) 'mobile_face_detection_web.dart' as mobile; // For FaceDetectionResult

class TensorflowFaceDetection {
  static Future<bool> initialize() async {
    // TensorFlow Lite is not supported on web
    return false;
  }

  static Future<mobile.FaceDetectionResult> processFrame(
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    // TensorFlow Lite is not supported on web
    return mobile.FaceDetectionResult(
      faceDetected: false,
      leftEyeClosed: false,
      rightEyeClosed: false,
      mouthOpen: false,
      boundingBoxes: {},
    );
  }

  static bool isSupported() {
    // TensorFlow Lite is not supported on web
    return false;
  }

  static void dispose() {
    // TensorFlow Lite is not supported on web
  }
}