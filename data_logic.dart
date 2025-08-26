// data_logic.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataLogic with ChangeNotifier {
  // Driver statistics
  int _totalAlerts = 0;
  int _highAlarms = 0;
  int _safeDrivingScore = 100;
  int _usagePercentage = 0;
  
  // Detailed statistics
  int _todayAlerts = 0;
  int _weeklyAlerts = 0;
  int _monthlyAlerts = 0;
  int _totalDrivingTime = 0; // in minutes
  
  // Weekly statistics (last 7 days)
  final Map<String, int> _weeklyStats = {};

  // Singleton pattern
  static final DataLogic _instance = DataLogic._internal();
  factory DataLogic() => _instance;
  DataLogic._internal();

  // Getters
  int get totalAlerts => _totalAlerts;
  int get highAlarms => _highAlarms;
  int get safeDrivingScore => _safeDrivingScore;
  int get usagePercentage => _usagePercentage;
  int get todayAlerts => _todayAlerts;
  int get weeklyAlerts => _weeklyAlerts;
  int get monthlyAlerts => _monthlyAlerts;
  int get totalDrivingTime => _totalDrivingTime;
  Map<String, int> get weeklyStats => Map.unmodifiable(_weeklyStats);

  // Methods to update statistics
  void incrementAlerts() {
    _totalAlerts++;
    _todayAlerts++;
    _updateWeeklyStats();
    _updateSafeDrivingScore();
    notifyListeners();
    // Save data after each update
    saveData();
  }

  void incrementHighAlarms() {
    _highAlarms++;
    _updateSafeDrivingScore();
    notifyListeners();
    // Save data after each update
    saveData();
  }

  void updateUsagePercentage(int percentage) {
    if (percentage >= 0 && percentage <= 100) {
      _usagePercentage = percentage;
      notifyListeners();
      // Save data after each update
      saveData();
    }
  }

  void addDrivingTime(int minutes) {
    if (minutes > 0) {
      _totalDrivingTime += minutes;
      notifyListeners();
      // Save data after each update
      saveData();
    }
  }

  void _updateWeeklyStats() {
    // Get current day (simplified)
    final day = DateTime.now().weekday.toString();
    _weeklyStats.update(day, (value) => value + 1, ifAbsent: () => 1);
    
    // Update weekly and monthly counts
    _weeklyAlerts = _weeklyStats.values.fold(0, (sum, value) => sum + value);
    _monthlyAlerts = _weeklyAlerts * 4; // Simplified monthly calculation
    
    notifyListeners();
  }

  void _updateSafeDrivingScore() {
    // More sophisticated algorithm to calculate safe driving score
    int score = 100;
    
    // Deduct points for alerts (max 30 points)
    score -= (_totalAlerts * 1).clamp(0, 30);
    
    // Deduct more points for high alarms (max 40 points)
    score -= (_highAlarms * 3).clamp(0, 40);
    
    // Bonus for low usage (if usage is low, it might mean less driving time)
    if (_usagePercentage < 30) {
      score += 5;
    }
    
    // Ensure score is between 0 and 100
    _safeDrivingScore = score.clamp(0, 100);
    
    notifyListeners();
  }

  // Load data from persistent storage
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load statistics
      _totalAlerts = prefs.getInt('totalAlerts') ?? 0;
      _highAlarms = prefs.getInt('highAlarms') ?? 0;
      _safeDrivingScore = prefs.getInt('safeDrivingScore') ?? 100;
      _usagePercentage = prefs.getInt('usagePercentage') ?? 0;
      _todayAlerts = prefs.getInt('todayAlerts') ?? 0;
      _weeklyAlerts = prefs.getInt('weeklyAlerts') ?? 0;
      _monthlyAlerts = prefs.getInt('monthlyAlerts') ?? 0;
      _totalDrivingTime = prefs.getInt('totalDrivingTime') ?? 0;
      
      // Load weekly stats
      _weeklyStats.clear();
      final weeklyStatsKeys = prefs.getStringList('weeklyStatsKeys') ?? [];
      final weeklyStatsValues = prefs.getStringList('weeklyStatsValues') ?? [];
      
      for (int i = 0; i < weeklyStatsKeys.length && i < weeklyStatsValues.length; i++) {
        final key = weeklyStatsKeys[i];
        final value = int.tryParse(weeklyStatsValues[i]) ?? 0;
        _weeklyStats[key] = value;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Use default values if loading fails
      notifyListeners();
    }
  }

  // Save data to persistent storage
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save statistics
      await prefs.setInt('totalAlerts', _totalAlerts);
      await prefs.setInt('highAlarms', _highAlarms);
      await prefs.setInt('safeDrivingScore', _safeDrivingScore);
      await prefs.setInt('usagePercentage', _usagePercentage);
      await prefs.setInt('todayAlerts', _todayAlerts);
      await prefs.setInt('weeklyAlerts', _weeklyAlerts);
      await prefs.setInt('monthlyAlerts', _monthlyAlerts);
      await prefs.setInt('totalDrivingTime', _totalDrivingTime);
      
      // Save weekly stats
      final weeklyStatsKeys = _weeklyStats.keys.toList();
      final weeklyStatsValues = _weeklyStats.values.map((value) => value.toString()).toList();
      await prefs.setStringList('weeklyStatsKeys', weeklyStatsKeys);
      await prefs.setStringList('weeklyStatsValues', weeklyStatsValues);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Reset daily stats
  void resetDailyStats() {
    _todayAlerts = 0;
    notifyListeners();
    // Save data after each update
    saveData();
  }

  // Get safety rating based on score
  String getSafetyRating() {
    if (_safeDrivingScore >= 90) return 'Excellent';
    if (_safeDrivingScore >= 75) return 'Good';
    if (_safeDrivingScore >= 60) return 'Fair';
    if (_safeDrivingScore >= 40) return 'Poor';
    return 'Critical';
  }

  // Get improvement suggestions
  List<String> getImprovementSuggestions() {
    final suggestions = <String>[];
    
    if (_highAlarms > 5) {
      suggestions.add('Reduce high alert incidents by taking more frequent breaks');
    }
    
    if (_totalAlerts > 20) {
      suggestions.add('Consider adjusting sensitivity settings');
    }
    
    if (_usagePercentage < 30) {
      suggestions.add('Use the app more consistently for better monitoring');
    }
    
    if (_totalDrivingTime > 300) { // 5 hours
      suggestions.add('Take longer breaks during extended driving sessions');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('Keep up the good work! Your driving habits are excellent.');
    }
    
    return suggestions;
  }
}