package org.arb.wrkplantimesheetkiosk.Model;

public class EmployeeImageSettingsModel {
    String employee_code, id_person, name_first, name_last, employee_name, aws_face_id, aws_action;

    //--------getter method starts----

    public String getEmployee_code() {
        return employee_code;
    }

    public String getId_person() {
        return id_person;
    }

    public String getName_first() {
        return name_first;
    }

    public String getName_last() {
        return name_last;
    }

    public String getEmployee_name() {
        return employee_name;
    }

    public String getAws_face_id() {
        return aws_face_id;
    }

    public String getAws_action() {
        return aws_action;
    }

    //--------getter method ends----

    //--------setter method ends----

    public void setEmployee_code(String employee_code) {
        this.employee_code = employee_code;
    }

    public void setId_person(String id_person) {
        this.id_person = id_person;
    }

    public void setName_first(String name_first) {
        this.name_first = name_first;
    }

    public void setName_last(String name_last) {
        this.name_last = name_last;
    }

    public void setEmployee_name(String employee_name) {
        this.employee_name = employee_name;
    }

    public void setAws_face_id(String aws_face_id) {
        this.aws_face_id = aws_face_id;
    }

    public void setAws_action(String aws_action) {
        this.aws_action = aws_action;
    }

    //--------setter method ends----
}
