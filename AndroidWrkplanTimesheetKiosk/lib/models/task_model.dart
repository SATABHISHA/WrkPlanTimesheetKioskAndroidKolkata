// Mirrors EmployeeTimesheetModel.java from satabhisha
class TaskModel {
  String? costType;
  String? task;
  String? contract;
  String? note;
  String? laborCategory;
  String? hour;
  String? accountCode;
  String? employeeAssignmentID;
  int?    acSuffix;
  int?    laborCategoryID;
  int?    defaultTaskYn;
  int?    taskID;
  int?    costTypeID;
  int?    contractID;
  int?    tempDefault; // 1 if this is the default/selected task

  TaskModel({
    this.costType,
    this.task,
    this.contract,
    this.note,
    this.laborCategory,
    this.hour,
    this.accountCode,
    this.employeeAssignmentID,
    this.acSuffix,
    this.laborCategoryID,
    this.defaultTaskYn,
    this.taskID,
    this.costTypeID,
    this.contractID,
    this.tempDefault,
  });

  factory TaskModel.fromJson(Map<String, dynamic> j) {
    return TaskModel(
      costType:             j['CostType']?.toString(),
      task:                 j['Task']?.toString(),
      contract:             j['Contract']?.toString(),
      note:                 j['Note']?.toString(),
      laborCategory:        j['LaborCategory']?.toString(),
      hour:                 j['Hour']?.toString(),
      accountCode:          j['AccountCode']?.toString(),
      employeeAssignmentID: j['EmployeeAssignmentID']?.toString(),
      acSuffix:             j['ACSuffix'] is int ? j['ACSuffix'] as int : int.tryParse(j['ACSuffix']?.toString() ?? '0'),
      laborCategoryID:      j['LaborCategoryID'] is int ? j['LaborCategoryID'] as int : int.tryParse(j['LaborCategoryID']?.toString() ?? '0'),
      defaultTaskYn:        j['DefaultTaskYn'] is int ? j['DefaultTaskYn'] as int : int.tryParse(j['DefaultTaskYn']?.toString() ?? '0'),
      taskID:               j['TaskID'] is int ? j['TaskID'] as int : int.tryParse(j['TaskID']?.toString() ?? '0'),
      costTypeID:           j['CostTypeID'] is int ? j['CostTypeID'] as int : int.tryParse(j['CostTypeID']?.toString() ?? '0'),
      contractID:           j['ContractID'] is int ? j['ContractID'] as int : int.tryParse(j['ContractID']?.toString() ?? '0'),
      tempDefault:          (j['DefaultTaskYn'] is int ? j['DefaultTaskYn'] as int : int.tryParse(j['DefaultTaskYn']?.toString() ?? '0')) == 1 ? 1 : 0,
    );
  }

  // Round hours to 2 decimal places (mirrors TaskSelectionAdapter.round)
  double get parsedHour => double.tryParse(hour ?? '0') ?? 0.0;
}

// Mirrors LeaveBalanceItemsModel.java
class LeaveBalanceItem {
  String? leaveTypeName;
  String? balanceHrs;

  LeaveBalanceItem({this.leaveTypeName, this.balanceHrs});

  factory LeaveBalanceItem.fromJson(Map<String, dynamic> j) {
    return LeaveBalanceItem(
      leaveTypeName: j['leave_type_name']?.toString(),
      balanceHrs:    j['balance_hrs']?.toString(),
    );
  }
}
