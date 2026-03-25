import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/shared_preference_helper.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login({
    required String corpId,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        corpId: corpId,
        username: username,
        password: password,
      );

      if (response['Status'] == 'Success' || response['Status'] == 'Y') {
        _user = User.fromJson(response);
        
        // Save to local storage
        await _prefs.setUserData(response);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['Message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _prefs.clearUserData();
    await _prefs.clearUserToken();
    notifyListeners();
  }

  Future<void> restoreSession() async {
    try {
      final userData = _prefs.getUserData();
      if (userData != null) {
        _user = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors silently during session restore
    }
  }
}
