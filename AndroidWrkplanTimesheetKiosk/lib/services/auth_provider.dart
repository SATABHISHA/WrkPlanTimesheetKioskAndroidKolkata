import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/shared_preference_helper.dart';
import 'api_service.dart';

/// Mirrors the session state managed by UserSingletonModel + HomeLoginActivity
/// static fields in satabhisha.
///
/// Kiosk behaviour: the app always starts at LoginScreen — there is NO
/// automatic session restore.  The User object lives only in memory for the
/// duration of one kiosk session (login → punch/break → return to login).
class AuthProvider extends ChangeNotifier {
  final ApiService             _api   = ApiService();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  User?   _user;
  bool    _isLoading   = false;
  String? _errorMessage;

  // Runtime kiosk-session state (mirrors RecognitionOptionActivity statics)
  String? attendanceId;          // set after SaveAttendance
  String? employeeAssignmentID;  // set after punch IN
  bool    isInOutButtonHit = false;
  String  punchOutBreak    = 'out'; // 'out' or 'break'
  String  checkedInOut     = '';

  User?   get user         => _user;
  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;
  bool    get isLoggedIn   => _user != null;

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Mirrors HomeLoginActivity.login() and Admin LoginActivity.login().
  Future<bool> login({
    required String corpId,
    required String username,
    required String password,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deviceId = _generateDeviceId();
      final json = await _api.login(
        corpId:   corpId,
        username: username,
        password: password,
        deviceId: deviceId,
      );

      final status = json['status']?.toString() ?? '';
      if (status.toLowerCase() == 'true') {
        // Mirror: jsonObject.getJSONArray("UserLogin") → first element
        final userList = json['UserLogin'];
        final Map<String, dynamic> userData =
            (userList is List && userList.isNotEmpty)
                ? Map<String, dynamic>.from(userList.first as Map)
                : Map<String, dynamic>.from(json);

        _user = User.fromLoginJson(userData);
        // Mirror: editor.putString("CorpIdForUserAutofill", ...)
        await _prefs.saveCorpIdAutofill(corpId);
        await _prefs.saveUserSession(_user!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = json['message']?.toString() ?? 'Invalid login credentials';
        _isLoading    = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Could not connect to server';
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Session end (return to kiosk login screen) ────────────────────────────

  void endSession() {
    _user            = null;
    attendanceId     = null;
    employeeAssignmentID = null;
    isInOutButtonHit = false;
    punchOutBreak    = 'out';
    checkedInOut     = '';
    _errorMessage    = null;
    notifyListeners();
  }

  // ─── Device ID helper ──────────────────────────────────────────────────────

  /// Generates a stable pseudo device-ID stored in prefs (mirrors ANDROID_ID).
  String _generateDeviceId() {
    // Generates a pseudo device-ID; no persistent storage needed in kiosk mode
    try {
      // Will be '' on first launch — acceptably short-lived
      return SharedPreferenceHelper().getCorpIdAutofill().isNotEmpty
          ? 'kiosk_device'
          : _randomHex(16);
    } catch (_) {
      return _randomHex(16);
    }
  }

  String _randomHex(int length) {
    final rng = Random();
    return List.generate(length, (_) => rng.nextInt(16).toRadixString(16)).join();
  }
}

