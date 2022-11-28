package org.arb.wrkplantimesheetkiosk.Recognize;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.material.snackbar.Snackbar;

import org.arb.wrkplantimesheetkiosk.Adapter.CustomLeaveBalanceAdapter;
import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.LeaveBalanceItemsModel;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.XML;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

public class RecognitionOptionActivity extends AppCompatActivity implements View.OnClickListener {
    TextView tv_empname, tv_emp_id, tv_supervisor1, tv_supervisor2, tv_date, tv_time;
    RelativeLayout rl_punch_in, rl_break, rl_punch_out, rl_view_select_task, rl_view_leave_balance, rl_cancel;
    LinearLayout ll_break_punchout;
    TextView tv_view_leave_balance, tv_punchtitle1, tv_punchtitle2, tv_breaktitle1, tv_breaktitle2, tv_punch_out_title1, tv_punch_out_title2, tv_view_select_task, tv_cancel;
    public static String checkedInOut, punch_out_break;
    public static String attendance_id = "0", EmployeeAssignmentID = "0"; //--added on 07-Aug-2021
    public static Boolean IsInOutButtonHit; //--added on 09-Aug-2021
    ArrayList<LeaveBalanceItemsModel> leaveBalanceItemsModelArrayList = new ArrayList<>();

    SharedPreferences sharedPreferences;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recognize_option);

        attendance_id = "0"; //--added on 09-Aug-2021
        EmployeeAssignmentID = "0"; //--added on 09-Aug-2021
        IsInOutButtonHit = false;

        tv_empname = findViewById(R.id.tv_empname);
        tv_date = findViewById(R.id.tv_date);
        tv_time = findViewById(R.id.tv_time);
        tv_emp_id = findViewById(R.id.tv_emp_id);
        tv_supervisor1 = findViewById(R.id.tv_supervisor1);
        tv_supervisor2 = findViewById(R.id.tv_supervisor2);
        tv_view_leave_balance = findViewById(R.id.tv_view_leave_balance);

        rl_punch_in = findViewById(R.id.rl_punch_in);
        tv_punchtitle1 = findViewById(R.id.tv_punchtitle1);
        tv_punchtitle2 = findViewById(R.id.tv_punchtitle2);

        ll_break_punchout = findViewById(R.id.ll_break_punchout);
        rl_break = findViewById(R.id.rl_break);
        tv_breaktitle1 = findViewById(R.id.tv_breaktitle1);
        tv_breaktitle2 = findViewById(R.id.tv_breaktitle2);

        rl_punch_out = findViewById(R.id.rl_punch_out);
        tv_punch_out_title1 = findViewById(R.id.tv_punch_out_title1);
        tv_punch_out_title2 = findViewById(R.id.tv_punch_out_title2);

        rl_view_select_task = findViewById(R.id.rl_view_select_task);
        tv_view_select_task = findViewById(R.id.tv_view_select_task);

        rl_view_leave_balance = findViewById(R.id.rl_view_leave_balance);
        rl_cancel = findViewById(R.id.rl_cancel);
        tv_cancel = findViewById(R.id.tv_cancel);

        tv_empname.setText("Hello\n"+RecognizeHomeRealtimeActivity.EmployeeName);
//        tv_emp_id.setText(String.valueOf(RecognizeHomeRealtimeActivity.PersonId)); //---commented as said by manish da and told to set employeecode instead
        tv_emp_id.setText(RecognizeHomeRealtimeActivity.EmployeeCode);
        tv_supervisor1.setText(RecognizeHomeRealtimeActivity.Supervisor1);
        tv_supervisor2.setText(RecognizeHomeRealtimeActivity.Supervisor2);

        rl_punch_in.setVisibility(View.GONE);
        ll_break_punchout.setVisibility(View.GONE);

        checkAttendanceStatus();

        //=========get current date and set curretnt date, code starts========
        Date c = Calendar.getInstance().getTime();
        System.out.println("Current time => " + c);

        SimpleDateFormat df = new SimpleDateFormat("dd-MMM-yyyy", Locale.getDefault());
        SimpleDateFormat df_time = new SimpleDateFormat("HH:mm a", Locale.getDefault());
        String formattedDate = df.format(c);
        String formattedTime = df_time.format(c);

        tv_date.setText(formattedDate);
        tv_time.setText(formattedTime);
        //=========get current date and set curretnt date, code ends========

        rl_punch_in.setOnClickListener(this);
        tv_punchtitle1.setOnClickListener(this);
        tv_punchtitle2.setOnClickListener(this);

        rl_break.setOnClickListener(this);
        tv_breaktitle1.setOnClickListener(this);

        rl_punch_out.setOnClickListener(this);
        tv_punch_out_title1.setOnClickListener(this);
        tv_punch_out_title2.setOnClickListener(this);

        rl_view_select_task.setOnClickListener(this);
        tv_view_select_task.setOnClickListener(this);

        rl_view_leave_balance.setOnClickListener(this);
        tv_view_leave_balance.setOnClickListener(this);

        rl_cancel.setOnClickListener(this);
        tv_cancel.setOnClickListener(this);


        sharedPreferences = getApplication().getSharedPreferences("KioskDetails", Context.MODE_PRIVATE);
        //--to make visibilty on/of using shared pref, code starts
        if(sharedPreferences.getString("AttendanceYN","").contentEquals("0")){
            rl_punch_in.setVisibility(View.GONE);
            ll_break_punchout.setVisibility(View.GONE);
        }if(sharedPreferences.getString("TasklistYN","").contentEquals("0")){
            rl_view_select_task.setVisibility(View.GONE);
        }if(sharedPreferences.getString("LeaveBalanceYN","").contentEquals("0")){
            rl_view_leave_balance.setVisibility(View.GONE);
        }
        //--to make visibilty on/of using shared pref, code ends


    }

    public void checkAttendanceStatus(){
        String url = Config.BaseUrl + "KioskService.asmx/GetAttendanceNextAction";


        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait while loading data", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        JSONObject jsonObj = null;
                        try{
                            jsonObj = XML.toJSONObject(response);
                            String responseData = jsonObj.toString();
                            String val = "";
                            JSONObject resobj = new JSONObject(responseData);
                            Iterator<?> keys = resobj.keys();
                            while(keys.hasNext() ) {
                                String key = (String)keys.next();
                                if ( resobj.get(key) instanceof JSONObject ) {
                                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                                    val = xx.getString("content");
                                    Log.d("res1",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/


                                    if (jsonObject.getString("next_action").contentEquals("IN")) {
                                        rl_punch_in.setVisibility(View.VISIBLE);
                                        ll_break_punchout.setVisibility(View.GONE);
                                        rl_view_select_task.setVisibility(View.GONE); //--added on 19th feb

                                    } else if (jsonObject.getString("next_action").contentEquals("OUT")){
                                        rl_punch_in.setVisibility(View.GONE);
                                        ll_break_punchout.setVisibility(View.VISIBLE);
                                    }


                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }

                        }catch (Exception e){
                            e.printStackTrace();
                            loading.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();


                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

               /* View v = findViewById(R.id.relativeLayout);
                new org.arb.gst.config.Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());*/
                Toast.makeText(getApplicationContext(),message,Toast.LENGTH_LONG).show();
                Log.d("Volley Error-=>",error.toString());

                loading.dismiss();


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
//                params.put("CorpId", "arb-kol-dev");
                params.put("CorpId", userSingletonModel.getCorpID());
                params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("UserType", "MAIN");

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognitionOptionActivity.this);
        requestQueue.add(stringRequest);
    }

    public void saveInOut(String SaveInOut, String InOutText){
        String url = Config.BaseUrl + "KioskService.asmx/SaveAttendance";


        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait while loading data", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        JSONObject jsonObj = null;
                        try{
                            jsonObj = XML.toJSONObject(response);
                            String responseData = jsonObj.toString();
                            String val = "";
                            JSONObject resobj = new JSONObject(responseData);
                            Iterator<?> keys = resobj.keys();
                            while(keys.hasNext() ) {
                                String key = (String)keys.next();
                                if ( resobj.get(key) instanceof JSONObject ) {
                                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                                    val = xx.getString("content");
                                    Log.d("res1",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/

                                    attendance_id = jsonObject.getString("attendance_id");
                                    JSONObject jsonObjectResponse = jsonObject.getJSONObject("response"); //--added on 07-Aug-2021

                                    if (jsonObjectResponse.getString("status").contentEquals("true")) {
                                        if(SaveInOut.contentEquals("IN")) {
                                            Intent intent = new Intent(RecognitionOptionActivity.this, AttendanceRecordActivity.class);
                                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                                            startActivity(intent);
                                        }else{
                                            saveOnBreak();
                                            //--added on 23rd dec
                                            if (punch_out_break == "break"){
                                                saveOnBreak();
                                            }else if (punch_out_break == "out"){
                                                saveOn_PunchOut();
                                            }

                                            Intent intent = new Intent(RecognitionOptionActivity.this, PunchOutBreakActivity.class);
                                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                                            startActivity(intent);
                                        }


                                    } else {

                                    }


                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }

                        }catch (Exception e){
                            e.printStackTrace();
                            loading.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();


                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

               /* View v = findViewById(R.id.relativeLayout);
                new org.arb.gst.config.Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());*/
                Toast.makeText(getApplicationContext(),message,Toast.LENGTH_LONG).show();
                Log.d("Volley Error-=>",error.toString());

                loading.dismiss();


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
//                params.put("CorpId", "arb-kol-dev");
                params.put("CorpId", userSingletonModel.getCorpID());
                params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("UserType", "MAIN");
                params.put("InOut", SaveInOut);
                params.put("InOutText", InOutText);

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognitionOptionActivity.this);
        requestQueue.add(stringRequest);
    }

    public void saveOnBreak(){
        String url = Config.BaseUrl + "KioskService.asmx/TaskHourUpdate";


        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait while loading data", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        JSONObject jsonObj = null;
                        try{
                            jsonObj = XML.toJSONObject(response);
                            String responseData = jsonObj.toString();
                            String val = "";
                            JSONObject resobj = new JSONObject(responseData);
                            Iterator<?> keys = resobj.keys();
                            while(keys.hasNext() ) {
                                String key = (String)keys.next();
                                if ( resobj.get(key) instanceof JSONObject ) {
                                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                                    val = xx.getString("content");
                                    Log.d("res1",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/


                                    if (jsonObject.getString("status").contentEquals("true")) {
//                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show(); //--commenting on 18th feb


                                    } else {
                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show();
                                    }


                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }

                        }catch (Exception e){
                            e.printStackTrace();
                            loading.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();


                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

               /* View v = findViewById(R.id.relativeLayout);
                new org.arb.gst.config.Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());*/
                Toast.makeText(getApplicationContext(),message,Toast.LENGTH_LONG).show();
                Log.d("Volley Error-=>",error.toString());

                loading.dismiss();


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
//                params.put("CorpId", "arb-kol-dev");
                params.put("CorpId", userSingletonModel.getCorpID());
                params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("UserType", "MAIN");

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognitionOptionActivity.this);
        requestQueue.add(stringRequest);
    }

    public void saveOn_PunchOut(){
        String url = Config.BaseUrl + "KioskService.asmx/TaskHourSubmit";


        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait while loading data", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        JSONObject jsonObj = null;
                        try{
                            jsonObj = XML.toJSONObject(response);
                            String responseData = jsonObj.toString();
                            String val = "";
                            JSONObject resobj = new JSONObject(responseData);
                            Iterator<?> keys = resobj.keys();
                            while(keys.hasNext() ) {
                                String key = (String)keys.next();
                                if ( resobj.get(key) instanceof JSONObject ) {
                                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                                    val = xx.getString("content");
                                    Log.d("res1",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/


                                    if (jsonObject.getString("status").contentEquals("true")) {
//                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show(); //--commenting on 18th feb


                                    } else {
                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show();
                                    }


                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }

                        }catch (Exception e){
                            e.printStackTrace();
                            loading.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
//                loading.dismiss();


                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

               /* View v = findViewById(R.id.relativeLayout);
                new org.arb.gst.config.Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());*/
                Toast.makeText(getApplicationContext(),message,Toast.LENGTH_LONG).show();
                Log.d("Volley Error-=>",error.toString());

                loading.dismiss();


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
//                params.put("CorpId", "arb-kol-dev");
                params.put("CorpId", userSingletonModel.getCorpID());
                params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("UserType", "MAIN");

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognitionOptionActivity.this);
        requestQueue.add(stringRequest);
    }

    public void saveOn_Cancel(){
        String url = Config.BaseUrl + "KioskService.asmx/TaskHourSave";


        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait while loading data", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        JSONObject jsonObj = null;
                        try{
                            jsonObj = XML.toJSONObject(response);
                            String responseData = jsonObj.toString();
                            String val = "";
                            JSONObject resobj = new JSONObject(responseData);
                            Iterator<?> keys = resobj.keys();
                            while(keys.hasNext() ) {
                                String key = (String)keys.next();
                                if ( resobj.get(key) instanceof JSONObject ) {
                                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                                    val = xx.getString("content");
                                    Log.d("res1cancel-=>",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/


                                    if (jsonObject.getString("status").contentEquals("true")) {
//                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show(); //--commenting on 18th feb

                                        Intent intent = new Intent(RecognitionOptionActivity.this, HomeActivity.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                                        startActivity(intent);

                                    } else {
                                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"), Toast.LENGTH_LONG).show();
                                    }


                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }

                        }catch (Exception e){
                            e.printStackTrace();
                            loading.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();


                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

               /* View v = findViewById(R.id.relativeLayout);
                new org.arb.gst.config.Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());*/
                Toast.makeText(getApplicationContext(),message,Toast.LENGTH_LONG).show();
                Log.d("Volley Error-=>",error.toString());

                loading.dismiss();


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
//                params.put("CorpId", "arb-kol-dev");
                params.put("CorpId", userSingletonModel.getCorpID());
                params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("UserType", "MAIN");
                params.put("EmployeeAssignmentId", RecognitionOptionActivity.EmployeeAssignmentID); //--newly added on 07-Aug-2021
                params.put("KioskAttendanceId", RecognitionOptionActivity.attendance_id); //--newly added on 07-Aug-2021
                /*params.put("ContractId", "0");
                params.put("TaskId", "0");
                params.put("LaborCatId", "0");
                params.put("CostTypeId", "0");
                params.put("SuffixCode", "");*/ //--commented on 9th aug

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognitionOptionActivity.this);
        requestQueue.add(stringRequest);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.rl_punch_in:
                IsInOutButtonHit = true;
                saveInOut("IN","PUNCHED_IN");
                checkedInOut = "You are Punched IN";
                break;
            case R.id.tv_punchtitle1:
                IsInOutButtonHit = true;
                saveInOut("IN","PUNCHED_IN");
                checkedInOut = "You are Punched IN";
                break;
            case R.id.tv_punchtitle2:
                IsInOutButtonHit = true;
                saveInOut("IN","PUNCHED_IN");
                checkedInOut = "You are Punched IN";
                break;

            case R.id.rl_break:
//                break_punchout();
                checkedInOut = "You are on Break!";
                punch_out_break = "break";
                saveInOut("OUT","BREAK_STARTS");
                break;
            case R.id.tv_breaktitle1:
                checkedInOut = "You are on Break!";
                punch_out_break = "break";
                saveInOut("OUT","BREAK_STARTS");
                break;
            case R.id.tv_breaktitle2:
                checkedInOut = "You are on Break!";
                punch_out_break = "break";
                saveInOut("OUT","BREAK_STARTS");
                break;

            case R.id.rl_punch_out:
                break_punchout();
                break;
            case R.id.tv_punch_out_title1:
                break_punchout();
                break;
            case R.id.tv_punch_out_title2:
                break_punchout();
                break;

            case R.id.rl_view_select_task:
                Intent intent = new Intent(RecognitionOptionActivity.this,TaskSelectionActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                break;
            case R.id.tv_view_select_task:
                Intent intent1 = new Intent(RecognitionOptionActivity.this,TaskSelectionActivity.class);
                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent1);
                break;

            case R.id.rl_view_leave_balance:
                loadLeaveBalanceData();
                break;
            case R.id.tv_view_leave_balance:
                loadLeaveBalanceData();
                break;
            case R.id.rl_cancel:
                /*Intent intent_cancel = new Intent(this, HomeActivity.class);
                intent_cancel.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_cancel);*/
                saveOn_Cancel();
                break;
            case R.id.tv_cancel:
                /*Intent intent_cancel1 = new Intent(this, HomeActivity.class);
                intent_cancel1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_cancel1);*/
                saveOn_Cancel();
                break;
            default:
                break;
        }
    }

    //---popup for break and punchout, code starts
    public void break_punchout(){
        //-------custom dialog code starts=========
        LayoutInflater li2 = LayoutInflater.from(this);
        View dialog = li2.inflate(R.layout.dialog_punchout_break, null);
        LinearLayout ll_yes = dialog.findViewById(R.id.ll_yes);
        LinearLayout ll_no = dialog.findViewById(R.id.ll_no);


        androidx.appcompat.app.AlertDialog.Builder alert = new androidx.appcompat.app.AlertDialog.Builder(this);
        alert.setView(dialog);
        //Creating an alert dialog
        final androidx.appcompat.app.AlertDialog alertDialog = alert.create();
        alertDialog.show();
        ll_yes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertDialog.dismiss();
                saveInOut("OUT","PUNCHED_OUT");
                checkedInOut = "Good Bye!";
                punch_out_break = "out";
            }
        });
        ll_no.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
                saveInOut("OUT","BREAK_STARTS");
                checkedInOut = "You are on Break!";
                punch_out_break = "break";
            }
        });
        //-------custom dialog code ends=========
    }
    //---popup for break and punchout, code ends

    //==========function to load leave balance data from api, starts============
    public void loadLeaveBalanceData(){

        //--------------code to get current date and set in custom format, starts----------
        Date c = Calendar.getInstance().getTime();
        SimpleDateFormat df = new SimpleDateFormat("MM-dd-yyyy");
        final String WeekDate = df.format(c);
        //--------------code to get current date and set in custom format, ends----------
        /*if(userSingletonModel.getEmployeeYN().contentEquals("1") && !userSingletonModel.getTimesheet_personId_yn().contentEquals("2")) {
            WeekDatedynamic = TimesheetHome.dateOnSelectedCalender;
        }else if(userSingletonModel.getEmployeeYN().contentEquals("1") && userSingletonModel.getTimesheet_personId_yn().contentEquals("2")){
            WeekDatedynamic = ExpandableListNotStartedPendingItemsAdapter.weekDate;
        }
        else{
            WeekDatedynamic = TimesheetHome.period_date;
        }*/


        String url = Config.BaseUrl+"KioskService.asmx/LeaveBalance";
        final ProgressDialog loading = ProgressDialog.show(RecognitionOptionActivity.this, "Loading", "Please wait...", true, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new
                Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        getLeaveData(response);
                        loading.dismiss();
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();
                error.printStackTrace();
            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
              /*  params.put("UserId", userSingletonModel.getUserID());
                if(userSingletonModel.getEmployeeYN().contentEquals("1")) {
                    params.put("EmployeeID", userSingletonModel.getUserID());
//                    params.put("EmployeeID", "1");
                }else{
                    params.put("EmployeeID", userSingletonModel.getSub_updated_employee_id());
                }
                params.put("WeekDate",WeekDatedynamic);
                params.put("CompanyId",userSingletonModel.getCompID());
                params.put("CorpId", userSingletonModel.getCorpID()); */

//                params.put("CorpId","arb-kol-dev");
                params.put("CorpId",userSingletonModel.getCorpID());
                params.put("EmployeeId",String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
                params.put("DateToday",WeekDate);
                return params;
            }

        };
        stringRequest.setRetryPolicy(new DefaultRetryPolicy(10000,
                DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        RequestQueue queue = Volley.newRequestQueue(this);
        queue.add(stringRequest);
    }
    public void getLeaveData(String request){
        JSONObject jsonObj = null;
        try {
            jsonObj = XML.toJSONObject(request);
            String responseData = jsonObj.toString();
            String val = "";
            JSONObject resobj = new JSONObject(responseData);
            Log.d("getLeaveData",responseData.toString());
            if(!leaveBalanceItemsModelArrayList.isEmpty()){
                leaveBalanceItemsModelArrayList.clear();
            }

            Iterator<?> keys = resobj.keys();
            while(keys.hasNext() ) {
                String key = (String) keys.next();
                if (resobj.get(key) instanceof JSONObject) {
                    JSONObject xx = new JSONObject(resobj.get(key).toString());
                    Log.d("getLeaveData1",xx.getString("content"));
                    JSONObject jsonObject = new JSONObject(xx.getString("content"));
                    String status = jsonObject.getString("status");
                    String dateLeaveUpto = jsonObject.getString("LeaveDateUpto");
                    if(status.trim().contentEquals("true")){
                        JSONObject jsonObject1 = jsonObject.getJSONObject("LeaveBalanceItems");
                        Log.d("getLeavedata2",jsonObject1.toString());
                        //-------custom dialog code starts=========
                        LayoutInflater li2 = LayoutInflater.from(this);
                        View dialog = li2.inflate(R.layout.dialog_leave_balance, null);
                        TextView tv_blnc_week_date = dialog.findViewById(R.id.tv_blnc_week_date);
                        TextView tv_employee_name = dialog.findViewById(R.id.tv_employee_name);
//                        TextView tv_employee = dialog.findViewById(R.id.tv_employee);
                        TextView tv_blnc = dialog.findViewById(R.id.tv_blnc);
                        ListView lv_leave_blnc = dialog.findViewById(R.id.lv_leave_blnc);
//                        LinearLayout linearlayout2 = dialog.findViewById(R.id.linearlayout2);

                        tv_blnc_week_date.setVisibility(View.VISIBLE);
                        tv_employee_name.setVisibility(View.VISIBLE);
//                        tv_employee.setVisibility(View.VISIBLE);
                        tv_blnc.setVisibility(View.VISIBLE);
//                        linearlayout2.setVisibility(View.VISIBLE);

                        tv_employee_name.setText(RecognizeHomeRealtimeActivity.EmployeeName);


                        tv_blnc_week_date.setText(dateLeaveUpto);
                        Iterator<String> keys1 = jsonObject1.keys();
                        while(keys1.hasNext() ) {
                            String key1 = (String)keys1.next();
                            LeaveBalanceItemsModel leaveBalanceItemsModel = new LeaveBalanceItemsModel();
                            leaveBalanceItemsModel.setPersonal(key1.replace(":",""));
                            leaveBalanceItemsModel.setPersonalHrs(jsonObject1.get(key1).toString());
                            leaveBalanceItemsModelArrayList.add(leaveBalanceItemsModel);

                        }

                        lv_leave_blnc.setVisibility(View.VISIBLE);

                        lv_leave_blnc.setAdapter(new CustomLeaveBalanceAdapter(this,leaveBalanceItemsModelArrayList));


                        RelativeLayout relativeLayout_ok = (RelativeLayout) dialog.findViewById(R.id.relativeLayout_ok);
                        androidx.appcompat.app.AlertDialog.Builder alert = new androidx.appcompat.app.AlertDialog.Builder(this);
                        alert.setView(dialog);
                        //Creating an alert dialog
                        final androidx.appcompat.app.AlertDialog alertDialog = alert.create();
                        alertDialog.show();
                        relativeLayout_ok.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                alertDialog.dismiss();
                            }
                        });
                        //-------custom dialog code ends=========


                    }else if(status.trim().contentEquals("false")){
//                        Toast.makeText(getApplicationContext(),jsonObject.getString("message"),Toast.LENGTH_LONG).show();
                        String message = jsonObject.getString("message");
//                        int color = Color.parseColor("#AE0000");
                        int color = Color.parseColor("#ffffff");
                        Snackbar snackbar = Snackbar.make(findViewById(R.id.cordinatorLayout), message, 4000);

                        View sbView = snackbar.getView();
                        TextView textView = (TextView) sbView.findViewById(com.google.android.material.R.id.snackbar_text);
                        textView.setTextColor(color);
                        snackbar.show();
                    }


                }
            }
        }catch (JSONException e){
            e.printStackTrace();
        }
    }
    //==========function to load leave balance data, ends============
}
