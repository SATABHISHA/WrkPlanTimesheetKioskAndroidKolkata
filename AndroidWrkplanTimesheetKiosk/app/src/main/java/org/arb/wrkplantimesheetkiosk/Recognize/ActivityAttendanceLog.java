package org.arb.wrkplantimesheetkiosk.Recognize;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.DatePicker;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import org.arb.wrkplantimesheetkiosk.Home.HomeLoginActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

public class ActivityAttendanceLog extends AppCompatActivity {
    TextView tv_empname, tv_emp_name_body;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    LinearLayout ll_log_header, ll_log_break;
    LinearLayout logContainer, ll_log_break_entries;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_attendance_log);
        tv_empname = findViewById(R.id.tv_empname);
        tv_emp_name_body = findViewById(R.id.tv_emp_name_body);
        ll_log_header = findViewById(R.id.ll_log_header);
        ll_log_break = findViewById(R.id.ll_log_break);
        logContainer = findViewById(R.id.ll_log_entries);
        ll_log_break_entries = findViewById(R.id.ll_log_break_entries);
        tv_empname.setText("Hello\n"+ HomeLoginActivity.EmployeeName);
        // Initialize Spinner
        Spinner spinner = findViewById(R.id.spinner_choices);

        if(userSingletonModel.getSupervisorYNTemp().contentEquals("0")){
            tv_emp_name_body.setVisibility(View.VISIBLE);
            spinner.setVisibility(View.GONE);
            tv_emp_name_body.setText(HomeLoginActivity.EmployeeName);
        }else{
            tv_emp_name_body.setVisibility(View.GONE);
            spinner.setVisibility(View.VISIBLE);

            // Create array for dropdown
            String[] items = {"Valatka Nicole","Henry McBride"};

            // Create an ArrayAdapter using the string array and a default spinner layout
            ArrayAdapter<String> adapter = new ArrayAdapter<>(
                    this,
                    android.R.layout.simple_spinner_item,
                    items
            );

            // Specify the layout to use when the list of choices appears
            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

            // Apply the adapter to the spinner
            spinner.setAdapter(adapter);
        }





        //---code to show static data, starts
        // Sample JSON data
        String jsonData = "{ \"attendance_log\": [" +
                "{\"time_in\": \"11:37 AM\", \"time_out\": \"11:45 AM\"}," +
                "{\"time_in\": \"11:47 AM\", \"time_out\": \"04:54 PM\"}," +
                "{\"time_in\": \"04:56 PM\", \"time_out\": \"04:58 PM\"}," +
                "]}";

        try {
            JSONObject jsonObject = new JSONObject(jsonData);
            JSONArray attendanceLog = jsonObject.getJSONArray("attendance_log");

            displayAttendanceLog(attendanceLog);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        //---code to show static data, ends

        //---json break
        String jsonDataBreak = "{ \"attendance_log_break\": [" +
                "{\"start\": \"11:45 AM\", \"end\": \"11:47 AM\", \"duration\": \"2 mins\" }," +
                "{\"start\": \"04:54 PM\", \"end\": \"04:56 PM\", \"duration\": \"2 mins\" }," +
                "]}";

        try {
            JSONObject jsonObject = new JSONObject(jsonDataBreak);
            JSONArray attendanceLogBreak = jsonObject.getJSONArray("attendance_log_break");

            displayAttendanceLogBreak(attendanceLogBreak);
        } catch (JSONException e) {
            e.printStackTrace();
        }


    }


    //---function to display static attendance log
    public void displayAttendanceLogBreak(JSONArray attendanceLog) {
//        LinearLayout logContainer = findViewById(R.id.ll_log_entries);

        for (int i = 0; i < attendanceLog.length(); i++) {
            try {
                JSONObject logEntry = attendanceLog.getJSONObject(i);
                String timeStart = logEntry.getString("start");
                String timeEnd = logEntry.getString("end");
                String duration = logEntry.getString("duration");

                // Inflate a new row
                View rowView = LayoutInflater.from(this).inflate(R.layout.custom_attendance_break, ll_log_break_entries, false);
                TextView tv_start = rowView.findViewById(R.id.tv_start);
                TextView tv_end = rowView.findViewById(R.id.tv_end);
                TextView tv_duration = rowView.findViewById(R.id.tv_duration);

                tv_start.setText(timeStart);
                tv_end.setText(timeEnd);
                tv_duration.setText(duration);


                ll_log_break_entries.addView(rowView);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    //---function to display static attendance log
    public void displayAttendanceLog(JSONArray attendanceLog) {
//        LinearLayout logContainer = findViewById(R.id.ll_log_entries);

        for (int i = 0; i < attendanceLog.length(); i++) {
            try {
                JSONObject logEntry = attendanceLog.getJSONObject(i);
                String timeIn = logEntry.getString("time_in");
                String timeOut = logEntry.getString("time_out");

                // Inflate a new row
                View rowView = LayoutInflater.from(this).inflate(R.layout.custom_attendance_row, logContainer, false);
                TextView tvTimeIn = rowView.findViewById(R.id.tv_time_in);
                TextView tvTimeOut = rowView.findViewById(R.id.tv_time_out);

                tvTimeIn.setText(timeIn);
                tvTimeOut.setText(timeOut);

                logContainer.addView(rowView);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }


    // Method triggered by clicking the TextView with onClick="showDatePicker"
    public void showDatePicker(android.view.View view) {
        final Calendar calendar = Calendar.getInstance();

        // Create DatePickerDialog
        DatePickerDialog datePickerDialog = new DatePickerDialog(this,
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int month, int dayOfMonth) {
                        // Format date to dd-MM-yyyy
                        calendar.set(year, month, dayOfMonth);
                        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy", Locale.getDefault());
                        String formattedDate = sdf.format(calendar.getTime());

                        // Set selected date in TextView
                        TextView selectedDateTextView = findViewById(R.id.tv_selected_date);
                        selectedDateTextView.setText(formattedDate);

                        ll_log_header.setVisibility(View.VISIBLE);
                        ll_log_break.setVisibility(View.VISIBLE);
                        logContainer.setVisibility(View.VISIBLE);
                    }
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH));

        datePickerDialog.show();
    }


    @Override
    public void onBackPressed() {
        userSingletonModel.setSupervisorYNTemp(userSingletonModel.getSupervisorYN());
        Intent intent = new Intent(ActivityAttendanceLog.this, RecognitionOptionActivity.class);
//        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
//        super.onBackPressed();
    }
}
