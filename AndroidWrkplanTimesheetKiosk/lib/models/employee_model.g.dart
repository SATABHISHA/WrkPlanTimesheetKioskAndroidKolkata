// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  employeeCode: json['EmployeeCode'] as String?,
  employeeName: json['EmployeeName'] as String?,
  personId: (json['PersonId'] as num?)?.toInt(),
  supervisor1: json['Supervisor1'] as String?,
  supervisor2: json['Supervisor2'] as String?,
  imagePath: json['ImagePath'] as String?,
  department: json['Department'] as String?,
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'EmployeeCode': instance.employeeCode,
  'EmployeeName': instance.employeeName,
  'PersonId': instance.personId,
  'Supervisor1': instance.supervisor1,
  'Supervisor2': instance.supervisor2,
  'ImagePath': instance.imagePath,
  'Department': instance.department,
};
