import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'UserID')
  String? userID;
  
  @JsonKey(name: 'UserName')
  String? userName;
  
  @JsonKey(name: 'CompID')
  String? compID;
  
  @JsonKey(name: 'CorpID')
  String? corpID;
  
  @JsonKey(name: 'CompanyName')
  String? companyName;
  
  @JsonKey(name: 'SupervisorId')
  String? supervisorId;
  
  @JsonKey(name: 'UserRole')
  String? userRole;
  
  @JsonKey(name: 'AdminYN')
  String? adminYN;
  
  @JsonKey(name: 'PayableClerkYN')
  String? payableClerkYN;
  
  @JsonKey(name: 'SupervisorYN')
  String? supervisorYN;
  
  @JsonKey(name: 'PurchaseYN')
  String? purchaseYN;
  
  @JsonKey(name: 'PayrollClerkYN')
  String? payrollClerkYN;
  
  @JsonKey(name: 'EmpName')
  String? empName;
  
  @JsonKey(name: 'UserType')
  String? userType;
  
  @JsonKey(name: 'EmailId')
  String? emailId;
  
  @JsonKey(name: 'PwdSetterId')
  String? pwdSetterId;
  
  @JsonKey(name: 'FinYearID')
  String? finYearID;
  
  @JsonKey(name: 'Msg')
  String? msg;
  
  @JsonKey(name: 'EmailHostAddress')
  String? emailHostAddress;
  
  @JsonKey(name: 'EmailServer')
  String? emailServer;
  
  @JsonKey(name: 'EmailServerPort')
  String? emailServerPort;
  
  @JsonKey(name: 'EmailSendingUsername')
  String? emailSendingUsername;
  
  @JsonKey(name: 'EmailPassword')
  String? emailPassword;
  
  @JsonKey(name: 'SupervisorYNTemp')
  String? supervisorYNTemp;

  User({
    this.userID,
    this.userName,
    this.compID,
    this.corpID,
    this.companyName,
    this.supervisorId,
    this.userRole,
    this.adminYN,
    this.payableClerkYN,
    this.supervisorYN,
    this.purchaseYN,
    this.payrollClerkYN,
    this.empName,
    this.userType,
    this.emailId,
    this.pwdSetterId,
    this.finYearID,
    this.msg,
    this.emailHostAddress,
    this.emailServer,
    this.emailServerPort,
    this.emailSendingUsername,
    this.emailPassword,
    this.supervisorYNTemp,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => adminYN == 'Y' || adminYN == 'Yes';
  bool get isSupervisor => supervisorYN == 'Y' || supervisorYN == 'Yes';
}
