// auth_logic.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthLogic with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _user;
  String _userRole = 'driver'; // Default role

  // Singleton pattern
  static final AuthLogic _instance = AuthLogic._internal();
  factory AuthLogic() => _instance;
  AuthLogic._internal();

  bool get isLoggedIn => _user != null;
  String get username => _user?.displayName ?? _user?.email ?? '';
  String get userId => _user?.uid ?? '';
  String get userRole => _userRole;
  User? get user => _user;

  Future<void> initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    
    // Initialize with current user if already signed in
    _user = _auth.currentUser;
    _userRole = 'driver';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> updateProfile(String newUsername) async {
    if (_user != null && newUsername.isNotEmpty) {
      try {
        await _user!.updateDisplayName(newUsername);
        notifyListeners();
      } catch (e) {
        debugPrint('Profile update error: $e');
      }
    }
  }

  // Validate if user can access certain features based on role
  bool canAccessFeature(String feature) {
    // For now, all users can access all features
    // In a real app, this would check permissions based on user role
    return _user != null;
  }
}