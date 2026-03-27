// Mirrors EmployeeImageSettingsModel.java from satabhisha
class EmployeeImageSettings {
  String? employeeCode;
  String? idPerson;
  String? nameFirst;
  String? nameLast;
  String? employeeName;
  String? awsFaceId;
  String? awsAction; // 'enroll' or 'delete'

  EmployeeImageSettings({
    this.employeeCode,
    this.idPerson,
    this.nameFirst,
    this.nameLast,
    this.employeeName,
    this.awsFaceId,
    this.awsAction,
  });

  factory EmployeeImageSettings.fromJson(Map<String, dynamic> j) {
    return EmployeeImageSettings(
      employeeCode: j['employee_code']?.toString(),
      idPerson:     j['id_person']?.toString(),
      nameFirst:    j['name_first']?.toString(),
      nameLast:     j['name_last']?.toString(),
      employeeName: j['employee_name']?.toString(),
      awsFaceId:    j['aws_face_id']?.toString(),
      awsAction:    j['aws_action']?.toString(),
    );
  }

  String get fullName => '${nameFirst ?? ''} ${nameLast ?? ''}'.trim();
  bool   get hasImage => awsAction != 'enroll';
}

