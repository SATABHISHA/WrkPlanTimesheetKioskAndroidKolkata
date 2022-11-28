package org.arb.wrkplantimesheetkiosk.Model;

public class EmployeeTimesheetModel {
    String CostType, Task, Contract, Note, LaborCategory, Hour, AccountCode, EmployeeAssignmentID;
    Integer ACSuffix, LaborCategoryID, DefaultTaskYn, TaskID, CostTypeID, ContractID, tempDefault;

    //-----Getter method starts-----


    public String getEmployeeAssignmentID() {
        return EmployeeAssignmentID;
    }

    public String getCostType() {
        return CostType;
    }

    public String getTask() {
        return Task;
    }

    public String getContract() {
        return Contract;
    }

    public String getNote() {
        return Note;
    }

    public String getLaborCategory() {
        return LaborCategory;
    }

    public String getHour() {
        return Hour;
    }

    public String getAccountCode() {
        return AccountCode;
    }

    public Integer getACSuffix() {
        return ACSuffix;
    }

    public Integer getLaborCategoryID() {
        return LaborCategoryID;
    }

    public Integer getDefaultTaskYn() {
        return DefaultTaskYn;
    }

    public Integer getTaskID() {
        return TaskID;
    }

    public Integer getCostTypeID() {
        return CostTypeID;
    }

    public Integer getContractID() {
        return ContractID;
    }

    public Integer getTempDefault() {
        return tempDefault;
    }

    //-----Getter method ends-----

    //-----Setter method starts-----


    public void setEmployeeAssignmentID(String employeeAssignmentID) {
        EmployeeAssignmentID = employeeAssignmentID;
    }

    public void setCostType(String costType) {
        CostType = costType;
    }

    public void setTask(String task) {
        Task = task;
    }

    public void setContract(String contract) {
        Contract = contract;
    }

    public void setNote(String note) {
        Note = note;
    }

    public void setLaborCategory(String laborCategory) {
        LaborCategory = laborCategory;
    }

    public void setHour(String hour) {
        Hour = hour;
    }

    public void setAccountCode(String accountCode) {
        AccountCode = accountCode;
    }

    public void setACSuffix(Integer ACSuffix) {
        this.ACSuffix = ACSuffix;
    }

    public void setLaborCategoryID(Integer laborCategoryID) {
        LaborCategoryID = laborCategoryID;
    }

    public void setDefaultTaskYn(Integer defaultTaskYn) {
        DefaultTaskYn = defaultTaskYn;
    }

    public void setTaskID(Integer taskID) {
        TaskID = taskID;
    }

    public void setCostTypeID(Integer costTypeID) {
        CostTypeID = costTypeID;
    }

    public void setContractID(Integer contractID) {
        ContractID = contractID;
    }

    public void setTempDefault(Integer tempDefault) {
        this.tempDefault = tempDefault;
    }

    //-----Setter method ends-----

}
