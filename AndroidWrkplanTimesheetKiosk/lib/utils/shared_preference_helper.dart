import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

/// Mirrors the Android SharedPreferences pattern from satabhisha HomeLoginActivity.
/// Each user field is stored as an individual key (not serialised JSON).
class SharedPreferenceHelper {
  static final SharedPreferenceHelper _instance =
      SharedPreferenceHelper._internal();
  factory SharedPreferenceHelper() => _instance;
  SharedPreferenceHelper._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Corp-ID autofill (mirrors "CorpIdForUserAutofill") ──────────────────
  Future<void> saveCorpIdAutofill(String corpId) =>
      _prefs.setString(AppConstants.prefCorpIdAutofill, corpId);

  String getCorpIdAutofill() =>
      _prefs.getString(AppConstants.prefCorpIdAutofill) ?? '';

  // ─── Full user session (all individual keys, mirrors HomeLoginActivity) ──
  Future<void> saveUserSession(User user) async {
    await Future.wait([
      _prefs.setString(AppConstants.prefUserID,           user.userID ?? ''),
      _prefs.setString(AppConstants.prefUserName,         user.userName ?? ''),
      _prefs.setString(AppConstants.prefCompID,           user.compID ?? ''),
      _prefs.setString(AppConstants.prefCorpID,           user.corpID ?? ''),
      _prefs.setString(AppConstants.prefCompanyName,      user.companyName ?? ''),
      _prefs.setString(AppConstants.prefSupervisorId,     user.supervisorId ?? ''),
      _prefs.setString(AppConstants.prefUserRole,         user.userRole ?? ''),
      _prefs.setString(AppConstants.prefAdminYN,          user.adminYN ?? ''),
      _prefs.setString(AppConstants.prefPayableClerkYN,   user.payableClerkYN ?? ''),
      _prefs.setString(AppConstants.prefSupervisorYN,     user.supervisorYN ?? ''),
      _prefs.setString(AppConstants.prefPurchaseYN,       user.purchaseYN ?? ''),
      _prefs.setString(AppConstants.prefPayrollClerkYN,   user.payrollClerkYN ?? ''),
      _prefs.setString(AppConstants.prefEmpName,          user.empName ?? ''),
      _prefs.setString(AppConstants.prefUserType,         user.userType ?? ''),
      _prefs.setString(AppConstants.prefEmailId,          user.emailId ?? ''),
      _prefs.setString(AppConstants.prefPwdSetterId,      user.pwdSetterId ?? ''),
      _prefs.setString(AppConstants.prefFinYearID,        user.finYearID ?? ''),
      _prefs.setString(AppConstants.prefMsg,              user.msg ?? ''),
      _prefs.setString(AppConstants.prefEmailServer,      user.emailServer ?? ''),
      _prefs.setString(AppConstants.prefEmailServerPort,  user.emailServerPort ?? ''),
      _prefs.setString(AppConstants.prefEmailUsername,    user.emailSendingUsername ?? ''),
      _prefs.setString(AppConstants.prefEmailPassword,    user.emailPassword ?? ''),
      _prefs.setString(AppConstants.prefEmailHostAddress, user.emailHostAddress ?? ''),
      _prefs.setInt(AppConstants.prefPersonId,            user.personId ?? 0),
      _prefs.setString(AppConstants.prefEmployeeCode,     user.employeeCode ?? ''),
      _prefs.setString(AppConstants.prefSupervisor1,      user.supervisor1 ?? ''),
      _prefs.setString(AppConstants.prefSupervisor2,      user.supervisor2 ?? ''),
    ]);
  }

  /// Kiosk pattern: session is kept in prefs but the app always shows the
  /// login screen on launch — no automatic restore.
  Future<void> clearUserSession() async {
    final keys = [
      AppConstants.prefUserID, AppConstants.prefUserName, AppConstants.prefCompID,
      AppConstants.prefCorpID, AppConstants.prefCompanyName, AppConstants.prefSupervisorId,
      AppConstants.prefUserRole, AppConstants.prefAdminYN, AppConstants.prefPayableClerkYN,
      AppConstants.prefSupervisorYN, AppConstants.prefPurchaseYN, AppConstants.prefPayrollClerkYN,
      AppConstants.prefEmpName, AppConstants.prefUserType, AppConstants.prefEmailId,
      AppConstants.prefPwdSetterId, AppConstants.prefFinYearID, AppConstants.prefMsg,
      AppConstants.prefEmailServer, AppConstants.prefEmailServerPort,
      AppConstants.prefEmailUsername, AppConstants.prefEmailPassword,
      AppConstants.prefEmailHostAddress, AppConstants.prefEmployeeCode,
      AppConstants.prefSupervisor1, AppConstants.prefSupervisor2,
    ];
    await Future.wait(keys.map((k) => _prefs.remove(k)));
    await _prefs.remove(AppConstants.prefPersonId);
  }

  // ─── Kiosk settings ───────────────────────────────────────────────────────
  Future<void> saveOfficeLat(double lat) =>
      _prefs.setDouble(AppConstants.prefOfficeLat, lat);
  Future<void> saveOfficeLon(double lon) =>
      _prefs.setDouble(AppConstants.prefOfficeLon, lon);
  Future<void> savePunchRadius(double r) =>
      _prefs.setDouble(AppConstants.prefPunchRadius, r);

  double getOfficeLat() =>
      _prefs.getDouble(AppConstants.prefOfficeLat) ?? AppConstants.defaultOfficeLat;
  double getOfficeLon() =>
      _prefs.getDouble(AppConstants.prefOfficeLon) ?? AppConstants.defaultOfficeLon;
  double getPunchRadius() =>
      _prefs.getDouble(AppConstants.prefPunchRadius) ?? AppConstants.defaultPunchRadius;
}

