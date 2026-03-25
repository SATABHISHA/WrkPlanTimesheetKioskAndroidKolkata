import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class Employee {
  @JsonKey(name: 'EmployeeCode')
  String? employeeCode;
  
  @JsonKey(name: 'EmployeeName')
  String? employeeName;
  
  @JsonKey(name: 'PersonId')
  int? personId;
  
  @JsonKey(name: 'Supervisor1')
  String? supervisor1;
  
  @JsonKey(name: 'Supervisor2')
  String? supervisor2;
  
  @JsonKey(name: 'ImagePath')
  String? imagePath;
  
  @JsonKey(name: 'Department')
  String? department;

  Employee({
    this.employeeCode,
    this.employeeName,
    this.personId,
    this.supervisor1,
    this.supervisor2,
    this.imagePath,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
