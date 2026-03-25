// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      personId: (json['PersonId'] as num?)?.toInt(),
      employeeName: json['EmployeeName'] as String?,
      employeeCode: json['EmployeeCode'] as String?,
      attendanceDate: json['AttendanceDate'] as String?,
      checkInTime: json['CheckInTime'] as String?,
      checkOutTime: json['CheckOutTime'] as String?,
      attendanceStatus: json['AttendanceStatus'] as String?,
      task: json['Task'] as String?,
      imagePath: json['ImagePath'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'PersonId': instance.personId,
      'EmployeeName': instance.employeeName,
      'EmployeeCode': instance.employeeCode,
      'AttendanceDate': instance.attendanceDate,
      'CheckInTime': instance.checkInTime,
      'CheckOutTime': instance.checkOutTime,
      'AttendanceStatus': instance.attendanceStatus,
      'Task': instance.task,
      'ImagePath': instance.imagePath,
    };
