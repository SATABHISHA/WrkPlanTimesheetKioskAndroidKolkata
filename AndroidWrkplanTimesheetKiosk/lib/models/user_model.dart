// Mirrors UserSingletonModel.java + HomeLoginActivity static fields from satabhisha
class User {
  String? userID;
  String? userName;
  String? compID;
  String? corpID;
  String? companyName;
  String? supervisorId;
  String? userRole;
  String? adminYN;
  String? payableClerkYN;
  String? supervisorYN;
  String? supervisorYNTemp; // runtime overrideable copy
  String? purchaseYN;
  String? payrollClerkYN;
  String? empName;
  String? userType;
  String? emailId;
  String? pwdSetterId;
  String? finYearID;
  String? msg;
  String? emailHostAddress;
  String? emailServer;
  String? emailServerPort;
  String? emailSendingUsername;
  String? emailPassword;

  // From HomeLoginActivity static fields
  int?    personId;
  String? employeeCode;
  String? supervisor1;
  String? supervisor2;

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
    this.supervisorYNTemp,
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
    this.personId,
    this.employeeCode,
    this.supervisor1,
    this.supervisor2,
  });

  // Mirrors the JSON fields returned by ValidateTSheetKioskAdminLogin
  factory User.fromLoginJson(Map<String, dynamic> j) {
    return User(
      userID:              j['UserID']?.toString(),
      userName:            j['UserName']?.toString(),
      compID:              j['CompID']?.toString(),
      corpID:              j['CorpID']?.toString(),
      companyName:         j['CompanyName']?.toString(),
      supervisorId:        j['SupervisorId']?.toString(),
      userRole:            j['UserRole']?.toString(),
      adminYN:             j['AdminYN']?.toString(),
      payableClerkYN:      j['PayableClerkYN']?.toString(),
      supervisorYN:        j['SupervisorYN']?.toString(),
      supervisorYNTemp:    j['SupervisorYN']?.toString(), // same initial value
      purchaseYN:          j['PurchaseYN']?.toString(),
      payrollClerkYN:      j['PayrollClerkYN']?.toString(),
      empName:             j['EmpName']?.toString(),
      userType:            j['UserType']?.toString(),
      emailId:             j['EmailId']?.toString(),
      pwdSetterId:         j['PwdSetterId']?.toString(),
      finYearID:           j['FinYearID']?.toString(),
      msg:                 j['Msg']?.toString(),
      emailHostAddress:    j['EmailHostAddress']?.toString(),
      emailServer:         j['EmailServer']?.toString(),
      emailServerPort:     j['EmailServerPort']?.toString(),
      emailSendingUsername:j['EmailUsername']?.toString(),
      emailPassword:       j['EmailPassword']?.toString(),
      personId:            j['PersonId'] is int
                              ? j['PersonId'] as int
                              : int.tryParse(j['PersonId']?.toString() ?? ''),
      employeeCode:        j['EmployeeCode']?.toString(),
      supervisor1:         j['Supervisor1']?.toString(),
      supervisor2:         j['Supervisor2']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'UserID':           userID,
    'UserName':         userName,
    'CompID':           compID,
    'CorpID':           corpID,
    'CompanyName':      companyName,
    'SupervisorId':     supervisorId,
    'UserRole':         userRole,
    'AdminYN':          adminYN,
    'PayableClerkYN':   payableClerkYN,
    'SupervisorYN':     supervisorYN,
    'PurchaseYN':       purchaseYN,
    'PayrollClerkYN':   payrollClerkYN,
    'EmpName':          empName,
    'UserType':         userType,
    'EmailId':          emailId,
    'PwdSetterId':      pwdSetterId,
    'FinYearID':        finYearID,
    'Msg':              msg,
    'EmailHostAddress': emailHostAddress,
    'EmailServer':      emailServer,
    'EmailServerPort':  emailServerPort,
    'EmailUsername':    emailSendingUsername,
    'EmailPassword':    emailPassword,
    'PersonId':         personId,
    'EmployeeCode':     employeeCode,
    'Supervisor1':      supervisor1,
    'Supervisor2':      supervisor2,
  };

  bool get isAdmin      => adminYN == 'Y' || adminYN == 'Yes' || adminYN == '1';
  bool get isSupervisor => supervisorYNTemp == '1' || supervisorYNTemp == 'Y';
}

