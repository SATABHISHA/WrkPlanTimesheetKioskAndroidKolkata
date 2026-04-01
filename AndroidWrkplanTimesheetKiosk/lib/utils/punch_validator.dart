import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/app_colors.dart';
import 'shared_preference_helper.dart';

/// Validates biometric auth + office-coordinate proximity before any
/// Punch IN / Punch OUT / Break action.
///
/// Flow: authenticate → validate location → return true / show error dialog.
class PunchValidator {
  PunchValidator._();

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  /// Run the full validation chain.  Returns `true` only when both biometric
  /// authentication and location check pass.
  static Future<bool> validate(BuildContext context) async {
    // Step 1 – Biometric / device credential authentication
    final authPassed = await _authenticateBiometric(context);
    if (!authPassed) return false;

    // Step 2 – Location / coordinate validation
    final locationPassed = await _validateLocation(context);
    if (!locationPassed) return false;

    return true;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Step 1 – Biometric / device credential authentication
  // ────────────────────────────────────────────────────────────────────────────

  static Future<bool> _authenticateBiometric(BuildContext context) async {
    try {
      final bool canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canAuth) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            title: 'Authentication Unavailable',
            message:
                'No biometric or device lock is configured on this device. '
                'Please set up fingerprint, PIN, or pattern in your device settings.',
          );
        }
        return false;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed with punch action',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN / pattern as fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!authenticated && context.mounted) {
        _showErrorDialog(
          context,
          title: 'Authentication Failed',
          message: 'Biometric / device authentication was not successful. '
              'Please try again.',
        );
      }
      return authenticated;
    } on PlatformException catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          title: 'Authentication Error',
          message: e.message ?? 'An unexpected authentication error occurred.',
        );
      }
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Step 2 – Coordinate / location validation
  // ────────────────────────────────────────────────────────────────────────────

  static Future<bool> _validateLocation(BuildContext context) async {
    final officeLat   = _prefs.getOfficeLat();
    final officeLon   = _prefs.getOfficeLon();
    final punchRadius = _prefs.getPunchRadius();

    // If no office coordinates configured, skip location check
    if (officeLat == 0.0 && officeLon == 0.0) return true;

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          title: 'Location Permission Required',
          message: 'Location permission is required to punch in/out. '
              'Please grant location access in your device settings.',
        );
      }
      return false;
    }

    // GPS enabled?
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          title: 'Location Required',
          message: 'Please enable GPS / Location Services and try again.',
        );
      }
      return false;
    }

    // Obtain current position
    final Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          title: 'Location Error',
          message:
              'Unable to determine your current location. Please try again.',
        );
      }
      return false;
    }

    // Distance check
    final distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, officeLat, officeLon);

    if (distance > punchRadius) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          title: 'Out of Range',
          message:
              'You are ${distance.toStringAsFixed(0)} m away from the office. '
              'You must be within ${punchRadius.toStringAsFixed(0)} m to punch in/out.',
        );
      }
      return false;
    }

    return true;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Themed error dialog
  // ────────────────────────────────────────────────────────────────────────────

  static void _showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.punchOut, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.dialogText,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text(message,
            style: const TextStyle(
                color: AppColors.dialogText, fontSize: 16, height: 1.4)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dialogOk,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('OK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
