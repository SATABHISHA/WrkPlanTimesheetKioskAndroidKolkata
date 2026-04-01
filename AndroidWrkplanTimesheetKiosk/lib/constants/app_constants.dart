import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // Base URL — can be changed via KioskSettings
  static String baseUrl = 'http://14.99.211.60:9012/';
  static const String _prefBaseUrl = 'base_url';

  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefBaseUrl);
    if (saved != null && saved.isNotEmpty) baseUrl = saved;
  }

  static Future<void> saveBaseUrl(String url) async {
    baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBaseUrl, url);
  }

  // KioskService.asmx endpoints (matches satabhisha Config.java pattern)
  static String get kioskService => '${baseUrl}KioskService.asmx/';

  static String get loginEndpoint          => '${kioskService}ValidateTSheetKioskAdminLogin';
  static String get getNextActionEndpoint  => '${kioskService}GetAttendanceNextAction';
  static String get saveAttendanceEndpoint => '${kioskService}SaveAttendance';
  static String get taskListEndpoint       => '${kioskService}EmployeeTimeSheetDailyTaskList';
  static String get taskHourSaveEndpoint   => '${kioskService}TaskHourSave';
  static String get taskHourUpdateEndpoint => '${kioskService}TaskHourUpdate';
  static String get taskHourSubmitEndpoint => '${kioskService}TaskHourSubmit';
  static String get leaveBalanceEndpoint   => '${kioskService}LeaveBalance';
  static String get listFacesEndpoint      => '${kioskService}ListFaces';
  static String get indexFacesEndpoint     => '${kioskService}IndexFaces';
  static String get deleteFaceEndpoint     => '${kioskService}DeleteFaces';
  static String get createGalleryEndpoint  => '${kioskService}CreateGallery';
  static String get getKioskInfoEndpoint   => '${kioskService}GetKioskInfo';
  static String get saveKioskInfoEndpoint  => '${kioskService}SaveKioskInfo';

  // SharedPreferences keys (mirrors Android SharedPreferences keys)
  static const String prefUserID           = 'UserID';
  static const String prefUserName         = 'UserName';
  static const String prefCompID           = 'CompID';
  static const String prefCorpID           = 'CorpID';
  static const String prefCompanyName      = 'CompanyName';
  static const String prefSupervisorId     = 'SupervisorId';
  static const String prefUserRole         = 'UserRole';
  static const String prefAdminYN          = 'AdminYN';
  static const String prefPayableClerkYN   = 'PayableClerkYN';
  static const String prefSupervisorYN     = 'SupervisorYN';
  static const String prefPurchaseYN       = 'PurchaseYN';
  static const String prefPayrollClerkYN   = 'PayrollClerkYN';
  static const String prefEmpName          = 'EmpName';
  static const String prefUserType         = 'UserType';
  static const String prefEmailId          = 'EmailId';
  static const String prefPwdSetterId      = 'PwdSetterId';
  static const String prefFinYearID        = 'FinYearID';
  static const String prefMsg              = 'Msg';
  static const String prefEmailServer      = 'EmailServer';
  static const String prefEmailServerPort  = 'EmailServerPort';
  static const String prefEmailUsername    = 'EmailUsername';
  static const String prefEmailPassword    = 'EmailPassword';
  static const String prefEmailHostAddress = 'EmailHostAddress';
  static const String prefPersonId         = 'PersonId';
  static const String prefEmployeeCode     = 'EmployeeCode';
  static const String prefSupervisor1      = 'Supervisor1';
  static const String prefSupervisor2      = 'Supervisor2';
  static const String prefCorpIdAutofill   = 'CorpIdForUserAutofill';
  static const String prefOfficeLat        = 'office_latitude';
  static const String prefOfficeLon        = 'office_longitude';
  static const String prefPunchRadius      = 'punch_radius_meters';

  // Default office GPS (from satabhisha branch — Kolkata office coordinates)
  static const double defaultOfficeLat    = 22.574147;
  static const double defaultOfficeLon    = 88.4351112;
  static const double defaultPunchRadius  = 100.0; // metres

  // App info
  static const String appVersion = '1.11';
  static const String appName    = 'WrkPlan Timesheet Kiosk';
}
