import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceRecord {
  @JsonKey(name: 'PersonId')
  int? personId;
  
  @JsonKey(name: 'EmployeeName')
  String? employeeName;
  
  @JsonKey(name: 'EmployeeCode')
  String? employeeCode;
  
  @JsonKey(name: 'AttendanceDate')
  String? attendanceDate;
  
  @JsonKey(name: 'CheckInTime')
  String? checkInTime;
  
  @JsonKey(name: 'CheckOutTime')
  String? checkOutTime;
  
  @JsonKey(name: 'AttendanceStatus')
  String? attendanceStatus;
  
  @JsonKey(name: 'Task')
  String? task;
  
  @JsonKey(name: 'ImagePath')
  String? imagePath;

  AttendanceRecord({
    this.personId,
    this.employeeName,
    this.employeeCode,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.attendanceStatus,
    this.task,
    this.imagePath,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);
}
