import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final http.Client _httpClient = http.Client();

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Login request
  Future<Map<String, dynamic>> login({
    required String corpId,
    required String username,
    required String password,
  }) async {
    return post('${AppConstants.loginEndpoint}', {
      'CorpID': corpId,
      'UserName': username,
      'Password': password,
    });
  }

  // Recognition/Attendance check-in
  Future<Map<String, dynamic>> recordAttendance({
    required int personId,
    required String imageBase64,
    required String task,
    required String attendanceType, // 'checkin' or 'checkout'
  }) async {
    return post('${AppConstants.recognitionEndpoint}', {
      'PersonId': personId,
      'Image': imageBase64,
      'Task': task,
      'AttendanceType': attendanceType,
      'Timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get employee list
  Future<Map<String, dynamic>> getEmployeeList({
    required String corpId,
  }) async {
    return get('${AppConstants.employeeEndpoint}?CorpID=$corpId');
  }

  // Get attendance records
  Future<Map<String, dynamic>> getAttendanceRecords({
    required String corpId,
    required String startDate,
    required String endDate,
  }) async {
    return get(
      '${AppConstants.attendanceEndpoint}?CorpID=$corpId&StartDate=$startDate&EndDate=$endDate',
    );
  }

  // Helper method to handle responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
