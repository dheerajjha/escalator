import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> createUser(String displayName, String role) async {
    try {
      final user = await ApiService.createUser(displayName, role);
      _currentUser = user;

      // Save user ID to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> loadUser(int userId) async {
    try {
      final user = await ApiService.getUser(userId);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    if (_currentUser == null) return;

    try {
      await ApiService.updateFcmToken(_currentUser!.id, fcmToken);
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    notifyListeners();
  }
}
