// settings_logic.dart
import 'package:flutter/foundation.dart';
import 'data_logic.dart';

class SettingsLogic with ChangeNotifier {
  // Settings values
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _bluetoothAlertsEnabled = true;
  bool _autoStartScan = false;
  int _sensitivityLevel = 2; // 1-3 (low, medium, high)
  int _alertVolume = 70; // 0-100
  int _vibrationIntensity = 2; // 1-3 (low, medium, high)
  String _alertSound = 'default'; // default, beep, chime, etc.
  
  // Singleton pattern
  static final SettingsLogic _instance = SettingsLogic._internal();
  factory SettingsLogic() => _instance;
  SettingsLogic._internal();

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get bluetoothAlertsEnabled => _bluetoothAlertsEnabled;
  bool get autoStartScan => _autoStartScan;
  int get sensitivityLevel => _sensitivityLevel;
  int get alertVolume => _alertVolume;
  int get vibrationIntensity => _vibrationIntensity;
  String get alertSound => _alertSound;

  // Setters with notifyListeners
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setBluetoothAlertsEnabled(bool value) {
    _bluetoothAlertsEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setAutoStartScan(bool value) {
    _autoStartScan = value;
    notifyListeners();
    saveSettings();
  }

  void setSensitivityLevel(int level) {
    if (level >= 1 && level <= 3) {
      _sensitivityLevel = level;
      notifyListeners();
      saveSettings();
    }
  }

  void setAlertVolume(int volume) {
    if (volume >= 0 && volume <= 100) {
      _alertVolume = volume;
      notifyListeners();
      saveSettings();
    }
  }

  void setVibrationIntensity(int intensity) {
    if (intensity >= 1 && intensity <= 3) {
      _vibrationIntensity = intensity;
      notifyListeners();
      saveSettings();
    }
  }

  void setAlertSound(String sound) {
    _alertSound = sound;
    notifyListeners();
    saveSettings();
  }

  // Reset to default settings
  void resetToDefaults() {
    _notificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _bluetoothAlertsEnabled = true;
    _autoStartScan = false;
    _sensitivityLevel = 2;
    _alertVolume = 70;
    _vibrationIntensity = 2;
    _alertSound = 'default';
    notifyListeners();
    saveSettings();
  }

  // Apply recommended settings based on user data
  void applyRecommendedSettings(DataLogic dataLogic) {
    // Adjust sensitivity based on user's alert history
    if (dataLogic.totalAlerts > 50) {
      _sensitivityLevel = 3; // High sensitivity
    } else if (dataLogic.totalAlerts > 20) {
      _sensitivityLevel = 2; // Medium sensitivity
    } else {
      _sensitivityLevel = 1; // Low sensitivity
    }
    
    // Adjust volume based on user's preferences
    if (dataLogic.safeDrivingScore > 80) {
      _alertVolume = 50; // Lower volume for experienced drivers
    } else {
      _alertVolume = 80; // Higher volume for new drivers
    }
    
    notifyListeners();
    saveSettings();
  }

  // Load settings from persistent storage (simulated)
  Future<void> loadSettings() async {
    // In a real app, this would load from shared preferences or similar
    // For now, we'll just use default values
    notifyListeners();
  }

  // Save settings to persistent storage (simulated)
  Future<void> saveSettings() async {
    // In a real app, this would save to shared preferences or similar
  }

  // Validate settings
  bool validateSettings() {
    // Check if at least one alert method is enabled
    if (!_notificationsEnabled && !_soundEnabled && !_vibrationEnabled) {
      return false;
    }
    
    // Check if sensitivity level is valid
    if (_sensitivityLevel < 1 || _sensitivityLevel > 3) {
      return false;
    }
    
    // Check if volume is valid
    if (_alertVolume < 0 || _alertVolume > 100) {
      return false;
    }
    
    // Check if vibration intensity is valid
    if (_vibrationIntensity < 1 || _vibrationIntensity > 3) {
      return false;
    }
    
    return true;
  }

  // Get sensitivity description
  String getSensitivityDescription() {
    switch (_sensitivityLevel) {
      case 1:
        return 'Low sensitivity - Fewer alerts, suitable for experienced drivers';
      case 2:
        return 'Medium sensitivity - Balanced alerts, suitable for most drivers';
      case 3:
        return 'High sensitivity - More alerts, suitable for new drivers';
      default:
        return 'Unknown sensitivity level';
    }
  }

  // Get alert sound description
  String getAlertSoundDescription() {
    switch (_alertSound) {
      case 'default':
        return 'Default alert sound';
      case 'beep':
        return 'Beep sound';
      case 'chime':
        return 'Chime sound';
      case 'voice':
        return 'Voice alert';
      default:
        return 'Custom sound';
    }
  }
}