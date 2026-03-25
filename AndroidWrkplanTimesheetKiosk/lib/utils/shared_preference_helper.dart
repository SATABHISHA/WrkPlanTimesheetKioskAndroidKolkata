import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class SharedPreferenceHelper {
  static final SharedPreferenceHelper _instance = SharedPreferenceHelper._internal();

  factory SharedPreferenceHelper() {
    return _instance;
  }

  SharedPreferenceHelper._internal();

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // User Token
  Future<void> setUserToken(String token) async {
    await _preferences.setString(AppConstants.userTokenKey, token);
  }

  String? getUserToken() {
    return _preferences.getString(AppConstants.userTokenKey);
  }

  Future<void> clearUserToken() async {
    await _preferences.remove(AppConstants.userTokenKey);
  }

  // User Data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    await _preferences.setString(
      AppConstants.userDataKey,
      jsonEncode(userData),
    );
  }

  Map<String, dynamic>? getUserData() {
    final String? userData = _preferences.getString(AppConstants.userDataKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _preferences.remove(AppConstants.userDataKey);
  }

  // Employee Data
  Future<void> setEmployeeData(List<Map<String, dynamic>> employeeData) async {
    await _preferences.setString(
      AppConstants.employeeDataKey,
      jsonEncode(employeeData),
    );
  }

  List<Map<String, dynamic>>? getEmployeeData() {
    final String? employeeData = _preferences.getString(AppConstants.employeeDataKey);
    if (employeeData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(employeeData));
    }
    return null;
  }

  Future<void> clearEmployeeData() async {
    await _preferences.remove(AppConstants.employeeDataKey);
  }

  // Clear All
  Future<void> clearAll() async {
    await _preferences.clear();
  }
}
