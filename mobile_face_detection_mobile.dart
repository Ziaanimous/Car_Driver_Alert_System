import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' show sqrt;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

/// Extension to calculate distance between Offset points
extension OffsetExtension on Offset {
  double get distance => sqrt(dx * dx + dy * dy);
}

/// Face detection implementation using Google ML Kit for mobile platforms
class MobileFaceDetection {
  static bool _initialized = false;
  static FaceMeshDetector? _faceMeshDetector;

  /// Initialize Google ML Kit for face detection
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize Google ML Kit Face Mesh Detection with better performance options
      _faceMeshDetector = FaceMeshDetector(
        option:
            FaceMeshDetectorOptions.values.first, // Use default options for now
      );

      _initialized = true;
      debugPrint('Face detection initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing face detection: $e');
      return false;
    }
  }

  /// Start face detection
  static Future<void> startDetection(
    void Function(FaceDetectionResult) onResult,
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    if (!_initialized) return;

    try {
      // Use Google ML Kit for face detection
      if (_faceMeshDetector != null) {
        final inputImage = _convertCameraImage(
          image,
          cameraDescription.sensorOrientation,
        );
        final meshes = await _faceMeshDetector!.processImage(inputImage);

        if (meshes.isNotEmpty) {
          final faceMesh = meshes.first;
          final points = faceMesh.points;

          // Extract face points for drowsiness detection
          final leftEyePoints = _getPoints(points, [
            33,
            133,
            160,
            159,
            158,
            153,
            144,
            145,
            153,
          ]);
          final rightEyePoints = _getPoints(points, [
            362,
            263,
            387,
            386,
            385,
            380,
            373,
            374,
            380,
          ]);
          final mouthPoints = _getPoints(points, [
            78,
            308,
            14,
            13,
            312,
            82,
            87,
            317,
            402,
            318,
          ]);

          // Check for drowsiness and yawning
          final isDrowsy = _isDrowsy(leftEyePoints, rightEyePoints);
          final isYawning = _isYawning(mouthPoints);

          // Create bounding boxes
          final leftEyeBox = _getBoundingBox(leftEyePoints);
          final rightEyeBox = _getBoundingBox(rightEyePoints);
          final mouthBox = _getBoundingBox(mouthPoints);

          final boundingBoxes = <String, Rect>{
            "leftEye": leftEyeBox,
            "rightEye": rightEyeBox,
            "mouth": mouthBox,
          };

          // Add drowsiness information
          if (isDrowsy) {
            boundingBoxes["leftEyeClosed"] = leftEyeBox;
            boundingBoxes["rightEyeClosed"] = rightEyeBox;
          }

          // Add yawning information
          if (isYawning) {
            boundingBoxes["mouthOpen"] = mouthBox;
          }

          final result = FaceDetectionResult(
            faceDetected: true,
            leftEyeClosed: isDrowsy,
            rightEyeClosed: isDrowsy,
            mouthOpen: isYawning,
            boundingBoxes: boundingBoxes,
          );

          onResult(result);
        } else {
          // No face detected
          onResult(
            FaceDetectionResult(
              faceDetected: false,
              leftEyeClosed: false,
              rightEyeClosed: false,
              mouthOpen: false,
              boundingBoxes: {},
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in face detection: $e');
      // Return a default result in case of error
      onResult(
        FaceDetectionResult(
          faceDetected: false,
          leftEyeClosed: false,
          rightEyeClosed: false,
          mouthOpen: false,
          boundingBoxes: {},
        ),
      );
    }
  }

  /// Stop face detection
  static void stopDetection() {
    debugPrint('Face detection stopped');
  }

  /// Dispose resources
  static void dispose() {
    _faceMeshDetector?.close();
    _initialized = false;
  }

  // Helper methods for face detection
  static InputImage _convertCameraImage(CameraImage image, int rotation) {
    final bytes = Uint8List.fromList(
      image.planes.map((p) => p.bytes).expand((x) => x).toList(),
    );
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rotationVal =
        InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;
    final formatVal =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotationVal,
        format: formatVal,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static List<Offset> _getPoints(
    List<FaceMeshPoint> allPoints,
    List<int> indices,
  ) {
    final List<Offset> points = [];

    for (int index in indices) {
      // Check if the index exists in the allPoints list to prevent RangeError
      if (index >= 0 && index < allPoints.length) {
        points.add(
          Offset(allPoints[index].x.toDouble(), allPoints[index].y.toDouble()),
        );
      }
    }

    return points;
  }

  static Rect _getBoundingBox(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    // Ensure we have valid values
    if (minX == double.infinity ||
        maxX == double.negativeInfinity ||
        minY == double.infinity ||
        maxY == double.negativeInfinity) {
      return Rect.zero;
    }

    // Add a small margin to the bounding box for better visualization
    double margin = 5.0;
    return Rect.fromLTRB(
      (minX - margin).clamp(0, double.infinity),
      (minY - margin).clamp(0, double.infinity),
      (maxX + margin).clamp(0, double.infinity),
      (maxY + margin).clamp(0, double.infinity),
    );
  }

  static bool _isDrowsy(
    List<Offset> leftEyePoints,
    List<Offset> rightEyePoints,
  ) {
    // Check if both eyes are closed
    bool leftEyeClosed = _isEyeClosed(leftEyePoints);
    bool rightEyeClosed = _isEyeClosed(rightEyePoints);

    // For better drowsiness detection, we'll consider it drowsy if:
    // 1. Both eyes are closed, OR
    // 2. One eye is closed and there's partial closure of the other
    // 3. Both eyes are significantly partially closed
    // This accounts for cases where a person is drowsy but one eye might not be fully closed

    // Calculate partial closure thresholds
    double leftEar = _calculateEar(leftEyePoints);
    double rightEar = _calculateEar(rightEyePoints);

    // If both eyes are fully closed
    if (leftEyeClosed && rightEyeClosed) {
      return true;
    }

    // If one eye is fully closed and the other is partially closed
    if (leftEyeClosed && rightEar < 0.3) {
      return true;
    }

    if (rightEyeClosed && leftEar < 0.3) {
      return true;
    }

    // If both eyes are significantly partially closed (both EAR < 0.25)
    if (leftEar < 0.25 && rightEar < 0.25) {
      return true;
    }
    
    // Additional check for drowsiness: if one eye is very closed and the other is moderately closed
    if ((leftEar < 0.2 && rightEar < 0.35) || (rightEar < 0.2 && leftEar < 0.35)) {
      return true;
    }

    return false;
  }

  /// Calculate Eye Aspect Ratio (EAR) for more precise detection
  static double _calculateEar(List<Offset> eyePoints) {
    if (eyePoints.length < 6) {
      return 1.0; // Return neutral value if not enough points
    }

    try {
      // Calculate distances between vertical eye landmarks
      double verticalDistance1 = (eyePoints[1] - eyePoints[5]).distance;
      double verticalDistance2 = (eyePoints[2] - eyePoints[4]).distance;

      // Calculate distance between horizontal eye landmarks
      double horizontalDistance = (eyePoints[0] - eyePoints[3]).distance;

      // Prevent division by zero
      if (horizontalDistance == 0) return 1.0;

      // Calculate EAR with additional validation
      double ear = (verticalDistance1 + verticalDistance2) / (2.0 * horizontalDistance);
      
      // Ensure EAR is within reasonable bounds (0.0 to 1.0)
      return ear.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('Error calculating EAR: $e');
      return 1.0; // Return neutral value on error
    }
  }

  static bool _isYawning(List<Offset> mouthPoints) {
    if (mouthPoints.length < 10) return false;

    try {
      // Calculate mouth height (distance between top and bottom lip)
      double mouthHeight = (mouthPoints[2].dy - mouthPoints[3].dy).abs();

      // Calculate mouth width (distance between left and right corner)
      double mouthWidth = (mouthPoints[0].dx - mouthPoints[1].dx).abs();

      // Prevent division by zero
      if (mouthWidth == 0) return false;

      // Yawning is detected when mouth is open wide (height/width ratio is high)
      double mouthRatio = mouthHeight / mouthWidth;

      // Using a more accurate threshold for yawning detection
      // A ratio of 0.45 or higher indicates yawning for better accuracy
      return mouthRatio > 0.45;
    } catch (e) {
      debugPrint('Error detecting yawning: $e');
      return false;
    }
  }

  static bool _isEyeClosed(List<Offset> eyePoints) {
    if (eyePoints.length < 6) return false;

    try {
      // Calculate eye height (distance between upper and lower eyelid)
      double eyeHeight = (eyePoints[1].dy - eyePoints[5].dy).abs();

      // Calculate eye width (distance between left and right corner)
      double eyeWidth = (eyePoints[0].dx - eyePoints[3].dx).abs();

      // Prevent division by zero
      if (eyeWidth == 0) return false;

      // Calculate eye aspect ratio (EAR)
      double ear = eyeHeight / eyeWidth;

      // Eye is considered closed when EAR is below threshold
      // Using a threshold of 0.22 for better accuracy
      return ear < 0.22;
    } catch (e) {
      debugPrint('Error detecting eye closure: $e');
      return false;
    }
  }
}

/// Face detection result structure
class FaceDetectionResult {
  final bool faceDetected;
  final bool leftEyeClosed;
  final bool rightEyeClosed;
  final bool mouthOpen;
  final Map<String, Rect> boundingBoxes;

  FaceDetectionResult({
    required this.faceDetected,
    required this.leftEyeClosed,
    required this.rightEyeClosed,
    required this.mouthOpen,
    required this.boundingBoxes,
  });
}