import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import '../constants/app_constants.dart';

/// Mirrors the Volley-based HTTP POST calls in satabhisha.
///
/// All KioskService.asmx endpoints accept application/x-www-form-urlencoded
/// POST bodies and return simple XML whose root-element text is a JSON string:
///
///   <string xmlns="http://tempuri.org/">{"status":"true",...}</string>
///
/// This is the same pattern that org.json.XML.toJSONObject() + content field
/// produced in the Android code.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const Duration _timeout = Duration(seconds: 35);

  // ─── Low-level XML/SOAP POST call ─────────────────────────────────────────

  /// Posts form params to [url] and returns the inner JSON object.
  Future<Map<String, dynamic>> _soapPost(
      String url, Map<String, String> params) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: params,
    ).timeout(_timeout);

    // Extract JSON string from XML: <RootElement>JSON_HERE</RootElement>
    final doc = XmlDocument.parse(response.body);
    final jsonString = doc.rootElement.innerText.trim();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // ─── Authentication ────────────────────────────────────────────────────────

  /// Mirrors HomeLoginActivity.login() / Admin LoginActivity.login()
  Future<Map<String, dynamic>> login({
    required String corpId,
    required String username,
    required String password,
    required String deviceId,
  }) =>
      _soapPost(AppConstants.loginEndpoint, {
        'CorpID':   corpId,
        'UserName': username,
        'Password': password,
        'DeviceID': deviceId,
      });

  // ─── Attendance ────────────────────────────────────────────────────────────

  /// Mirrors RecognitionOptionActivity.checkAttendanceStatus()
  Future<Map<String, dynamic>> getAttendanceNextAction({
    required String corpId,
    required int    userId,
  }) =>
      _soapPost(AppConstants.getNextActionEndpoint, {
        'CorpId':   corpId,
        'UserId':   userId.toString(),
        'UserType': 'MAIN',
      });

  /// Mirrors RecognitionOptionActivity.saveInOut()
  Future<Map<String, dynamic>> saveAttendance({
    required String corpId,
    required int    userId,
    required String inOut,     // 'IN' or 'OUT'
    required String inOutText, // 'PUNCHED_IN', 'BREAK_STARTS', 'PUNCH_OUT'
  }) =>
      _soapPost(AppConstants.saveAttendanceEndpoint, {
        'CorpId':   corpId,
        'UserId':   userId.toString(),
        'UserType': 'MAIN',
        'InOut':    inOut,
        'InOutText':inOutText,
      });

  // ─── Task / Timesheet ─────────────────────────────────────────────────────

  /// Mirrors TaskSelectionActivity.loadData()
  Future<Map<String, dynamic>> getTaskList({
    required String corpId,
    required int    userId,
  }) =>
      _soapPost(AppConstants.taskListEndpoint, {
        'CorpId':     corpId,
        'UserId':     userId.toString(),
        'deviceType': '1',
        'EmpType':    'MAIN',
      });

  /// Mirrors TaskSelectionActivity.save() — called after task selection
  Future<Map<String, dynamic>> taskHourSave({
    required String corpId,
    required int    userId,
    required String employeeAssignmentId,
    required String kioskAttendanceId,
    required int    contractId,
    required int    taskId,
    required int    laborCatId,
    required int    costTypeId,
    required int    suffixCode,
  }) =>
      _soapPost(AppConstants.taskHourSaveEndpoint, {
        'CorpId':               corpId,
        'UserId':               userId.toString(),
        'deviceType':           '1',
        'EmpType':              'MAIN',
        'EmployeeAssignmentId': employeeAssignmentId,
        'KioskAttendanceId':    kioskAttendanceId,
        'ContractId':           contractId.toString(),
        'TaskId':               taskId.toString(),
        'LaborCatId':           laborCatId.toString(),
        'CostTypeId':           costTypeId.toString(),
        'SuffixCode':           suffixCode.toString(),
      });

  /// Mirrors RecognitionOptionActivity.saveOnBreak() — on break start
  Future<Map<String, dynamic>> taskHourUpdate({
    required String corpId,
    required int    userId,
  }) =>
      _soapPost(AppConstants.taskHourUpdateEndpoint, {
        'CorpId':   corpId,
        'UserId':   userId.toString(),
        'UserType': 'MAIN',
      });

  /// Mirrors RecognitionOptionActivity.saveOn_PunchOut()
  Future<Map<String, dynamic>> taskHourSubmit({
    required String corpId,
    required int    userId,
  }) =>
      _soapPost(AppConstants.taskHourSubmitEndpoint, {
        'CorpId':   corpId,
        'UserId':   userId.toString(),
        'UserType': 'MAIN',
      });

  /// Mirrors AttendanceRecordActivity.saveOn_Cancel() / RecognitionOptionActivity.saveOn_Cancel()
  Future<Map<String, dynamic>> taskHourSaveOnCancel({
    required String corpId,
    required int    userId,
    required String employeeAssignmentId,
    required String kioskAttendanceId,
  }) =>
      _soapPost(AppConstants.taskHourSaveEndpoint, {
        'CorpId':               corpId,
        'UserId':               userId.toString(),
        'UserType':             'MAIN',
        'EmployeeAssignmentId': employeeAssignmentId,
        'KioskAttendanceId':    kioskAttendanceId,
      });

  // ─── Leave Balance ────────────────────────────────────────────────────────

  /// Mirrors AttendanceRecordActivity.loadLeaveBalanceData()
  Future<Map<String, dynamic>> getLeaveBalance({
    required String corpId,
    required int    employeeId,
  }) =>
      _soapPost(AppConstants.leaveBalanceEndpoint, {
        'CorpId': corpId,
        'EmployeeId': employeeId.toString(),
        'DateToday': DateFormat('MM-dd-yyyy').format(DateTime.now()),
      });

  // ─── Employee Image Settings ──────────────────────────────────────────────

  /// Mirrors EmployeeImageSettingsActivity.loadData()
  Future<Map<String, dynamic>> listFaces({required String corpId}) =>
      _soapPost(AppConstants.listFacesEndpoint, {'CorpId': corpId});

  /// Mirrors EmployeeImageSettingsAdapter EnrollImage()
  Future<Map<String, dynamic>> indexFaces({
    required String corpId,
    required String employeeId,
    required String imageBase64,
  }) =>
      _soapPost(AppConstants.indexFacesEndpoint, {
        'CorpId':      corpId,
        'EmployeeId':  employeeId,
        'ImageBase64': imageBase64,
      });

  /// Mirrors EmployeeImageSettingsAdapter delete image
  Future<Map<String, dynamic>> deleteFace({
    required String corpId,
    required String employeeId,
  }) =>
      _soapPost(AppConstants.deleteFaceEndpoint, {
        'CorpId':     corpId,
        'EmployeeId': employeeId,
      });

  /// Mirrors EmployeeImageSettingsActivity.createGallery()
  Future<Map<String, dynamic>> createGallery({required String corpId}) =>
      _soapPost(AppConstants.createGalleryEndpoint, {'CorpId': corpId});
}

