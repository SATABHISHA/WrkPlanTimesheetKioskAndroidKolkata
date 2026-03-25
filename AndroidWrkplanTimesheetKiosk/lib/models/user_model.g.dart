// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userID: json['UserID'] as String?,
  userName: json['UserName'] as String?,
  compID: json['CompID'] as String?,
  corpID: json['CorpID'] as String?,
  companyName: json['CompanyName'] as String?,
  supervisorId: json['SupervisorId'] as String?,
  userRole: json['UserRole'] as String?,
  adminYN: json['AdminYN'] as String?,
  payableClerkYN: json['PayableClerkYN'] as String?,
  supervisorYN: json['SupervisorYN'] as String?,
  purchaseYN: json['PurchaseYN'] as String?,
  payrollClerkYN: json['PayrollClerkYN'] as String?,
  empName: json['EmpName'] as String?,
  userType: json['UserType'] as String?,
  emailId: json['EmailId'] as String?,
  pwdSetterId: json['PwdSetterId'] as String?,
  finYearID: json['FinYearID'] as String?,
  msg: json['Msg'] as String?,
  emailHostAddress: json['EmailHostAddress'] as String?,
  emailServer: json['EmailServer'] as String?,
  emailServerPort: json['EmailServerPort'] as String?,
  emailSendingUsername: json['EmailSendingUsername'] as String?,
  emailPassword: json['EmailPassword'] as String?,
  supervisorYNTemp: json['SupervisorYNTemp'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'UserID': instance.userID,
  'UserName': instance.userName,
  'CompID': instance.compID,
  'CorpID': instance.corpID,
  'CompanyName': instance.companyName,
  'SupervisorId': instance.supervisorId,
  'UserRole': instance.userRole,
  'AdminYN': instance.adminYN,
  'PayableClerkYN': instance.payableClerkYN,
  'SupervisorYN': instance.supervisorYN,
  'PurchaseYN': instance.purchaseYN,
  'PayrollClerkYN': instance.payrollClerkYN,
  'EmpName': instance.empName,
  'UserType': instance.userType,
  'EmailId': instance.emailId,
  'PwdSetterId': instance.pwdSetterId,
  'FinYearID': instance.finYearID,
  'Msg': instance.msg,
  'EmailHostAddress': instance.emailHostAddress,
  'EmailServer': instance.emailServer,
  'EmailServerPort': instance.emailServerPort,
  'EmailSendingUsername': instance.emailSendingUsername,
  'EmailPassword': instance.emailPassword,
  'SupervisorYNTemp': instance.supervisorYNTemp,
};
