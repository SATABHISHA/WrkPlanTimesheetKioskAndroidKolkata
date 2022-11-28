package org.arb.wrkplantimesheetkiosk.Model;

public class LeaveBalanceItemsModel {
    String Personal, Vacation, PersonalHrs, VacationHrs;

    public String getPersonalHrs() {
        return PersonalHrs;
    }

    public void setPersonalHrs(String personalHrs) {
        PersonalHrs = personalHrs;
    }

    public String getVacationHrs() {
        return VacationHrs;
    }

    public void setVacationHrs(String vacationHrs) {
        VacationHrs = vacationHrs;
    }

    public String getPersonal() {
        return Personal;
    }

    public void setPersonal(String personal) {
        Personal = personal;
    }

    public String getVacation() {
        return Vacation;
    }

    public void setVacation(String vacation) {
        Vacation = vacation;
    }
}
