package org.arb.wrkplantimesheetkiosk.Recognize;

import static org.arb.wrkplantimesheetkiosk.Adapter.TaskSelectionAdapter.round;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Adapter.TaskSelectionAdapter;
import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.EmployeeTimesheetModel;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONArray;
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

public class TaskSelectionActivity extends AppCompatActivity implements View.OnClickListener{
    public static ArrayList<EmployeeTimesheetModel> employeeTimesheetModelArrayList = new ArrayList<>();
    RecyclerView recycler_view;
    LinearLayout ll_recycler;
    TextView tv_empname, tv_totalhrs, tv_date;
    public static TaskSelectionAdapter taskSelectionAdapter;
    public static TextView tv_done, tv_cancel;
//    public static String EmployeeAssignmentID; //--added on 07-Aug-2021
    public static Integer ContractID = 0, TaskId = 0, LaborCatId = 0, CostTypeId = 0, ACSuffix = 0;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_task_selection);
        ll_recycler = findViewById(R.id.ll_recycler);
        tv_done = findViewById(R.id.tv_done);
        tv_cancel = findViewById(R.id.tv_cancel);
        tv_empname = findViewById(R.id.tv_empname);
        tv_totalhrs = findViewById(R.id.tv_totalhrs);
        tv_date = findViewById(R.id.tv_date);

        tv_empname.setText(RecognizeHomeRealtimeActivity.EmployeeName);
        taskSelectionAdapter = new TaskSelectionAdapter(this,employeeTimesheetModelArrayList);

        //=========get current date and set curretnt date, code starts========
        Date c = Calendar.getInstance().getTime();
        System.out.println("Current time => " + c);

        SimpleDateFormat df = new SimpleDateFormat("dd-MMM-yyyy", Locale.getDefault());
        String formattedDate = df.format(c);

        tv_date.setText(formattedDate);
        //=========get current date and set curretnt date, code ends========

        //==========Recycler code initializing and setting layoutManager starts======
        recycler_view = findViewById(R.id.recycler_view);
        recycler_view.setHasFixedSize(true);
        recycler_view.setLayoutManager(new LinearLayoutManager(this));
        //==========Recycler code initializing and setting layoutManager ends======

        loadData();

        tv_done.setOnClickListener(this);
        tv_cancel.setOnClickListener(this);
    }

public void loadData(){
    String url = Config.BaseUrl + "KioskService.asmx/EmployeeTimeSheetDailyTaskList";
    final ProgressDialog loading = ProgressDialog.show(TaskSelectionActivity.this, "Loading", "Please wait while loading data", false, false);
    StringRequest stringRequest = new StringRequest(Request.Method.POST, url,
            new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    JSONObject jsonObj = null;
                    try{
                        if (!employeeTimesheetModelArrayList.isEmpty()){
                            employeeTimesheetModelArrayList.clear();
                        }
                        double total_hrs_count = 0;
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
                                Log.d("res1-=>",xx.getString("content"));
                                JSONObject jsonObject = new JSONObject(val);
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/

                                JSONArray jsonArray = jsonObject.getJSONArray("EmployeeTimeSheetDetails");
                                for(int i=0; i<jsonArray.length();i++){
                                    JSONObject jsonObject1 = jsonArray.getJSONObject(i);
                                    EmployeeTimesheetModel employeeTimesheetModel = new EmployeeTimesheetModel();
                                    employeeTimesheetModel.setCostType(jsonObject1.getString("CostType"));
                                    employeeTimesheetModel.setEmployeeAssignmentID(jsonObject1.getString("EmployeeAssignmentID")); //--added on 07-Aug-2021
                                    employeeTimesheetModel.setTask(jsonObject1.getString("Task"));
                                    employeeTimesheetModel.setContract(jsonObject1.getString("Contract"));
                                    employeeTimesheetModel.setNote(jsonObject1.getString("Note"));
                                    employeeTimesheetModel.setACSuffix(jsonObject1.getInt("ACSuffix"));
                                    employeeTimesheetModel.setLaborCategoryID(jsonObject1.getInt("LaborCategoryID"));
                                    employeeTimesheetModel.setDefaultTaskYn(jsonObject1.getInt("DefaultTaskYn"));
                                    employeeTimesheetModel.setTaskID(jsonObject1.getInt("TaskID"));
                                    employeeTimesheetModel.setLaborCategory(jsonObject1.getString("LaborCategory"));
                                    employeeTimesheetModel.setHour(jsonObject1.getString("Hour"));
                                    employeeTimesheetModel.setAccountCode(jsonObject1.getString("AccountCode"));
                                    employeeTimesheetModel.setCostTypeID(jsonObject1.getInt("CostTypeID"));
                                    employeeTimesheetModel.setContractID(jsonObject1.getInt("ContractID"));

                                    total_hrs_count = total_hrs_count + Double.parseDouble(jsonObject1.getString("Hour"));

                                    if(jsonObject1.getInt("DefaultTaskYn") == 1){
                                        employeeTimesheetModel.setTempDefault(1);
                                    }else{
                                        employeeTimesheetModel.setTempDefault(0);
                                    }

                                    employeeTimesheetModelArrayList.add(employeeTimesheetModel);
                                }

//                                tv_totalhrs.setText(String.valueOf(total_hrs_count)); //--commented on 16-Aug-2021
                                tv_totalhrs.setText(String.valueOf(round(Double.valueOf(total_hrs_count),2))); //--added on 16-aug-2021
//                                recycler_view.setAdapter(new TaskSelectionAdapter(TaskSelectionActivity.this, employeeTimesheetModelArrayList));
                                recycler_view.setAdapter(taskSelectionAdapter);
                                taskSelectionAdapter.notifyDataSetChanged(); //--added on 12th feb




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
//            params.put("CorpId", "arb-kol-dev");
            params.put("CorpId", userSingletonModel.getCorpID());
            params.put("UserId", String.valueOf(RecognizeHomeRealtimeActivity.PersonId));
            params.put("deviceType", "1");
            params.put("EmpType", "MAIN");

            return params;
        }
    };

    RequestQueue requestQueue = Volley.newRequestQueue(TaskSelectionActivity.this);
    requestQueue.add(stringRequest);
}
    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tv_done:
                Log.d("ContractID",ContractID.toString());
                Log.d("TaskId",TaskId.toString());
                Log.d("TaskId",TaskId.toString());
                Log.d("LaborCatId",LaborCatId.toString());
                Log.d("EmployeeAssignmentId", RecognitionOptionActivity.EmployeeAssignmentID);
                Log.d("KioskAttendanceId", RecognitionOptionActivity.attendance_id);
                if(RecognitionOptionActivity.IsInOutButtonHit == false){
                    saveInOut("TC","TASK_CHANGED");
                }else{
                    save();
                }
//                save();
                break;
            case R.id.tv_cancel:
                /*Intent intent = new Intent(TaskSelectionActivity.this, HomeActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);*/
                save();
                break;
            default:
                break;
        }
    }


    public void save(){
        String url = Config.BaseUrl + "KioskService.asmx/TaskHourSave";


        final ProgressDialog loading = ProgressDialog.show(TaskSelectionActivity.this, "Loading", "Please wait while loading data", false, false);
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
                                    Log.d("res1-=>",xx.getString("content"));
                                    JSONObject jsonObject = new JSONObject(val);
                                    String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);
                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),jsonObject.getString("message"),Toast.LENGTH_LONG).show(); //--commented on 25th feb as per discussion

                                    Intent intent = new Intent(TaskSelectionActivity.this, HomeActivity.class);
                                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                                    startActivity(intent);
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
               /* params.put("ContractId", String.valueOf(ContractID));
                params.put("TaskId", String.valueOf(TaskId));
                params.put("LaborCatId", String.valueOf(LaborCatId));
                params.put("CostTypeId", String.valueOf(CostTypeId));
                params.put("SuffixCode", String.valueOf(ACSuffix));*/ //--commenetd on 07-Aug-2021

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(TaskSelectionActivity.this);
        requestQueue.add(stringRequest);
    }

    //----added on 09-Aug-2021, to get attendenceid, code starts----
    public void saveInOut(String SaveInOut, String InOutText){
        String url = Config.BaseUrl + "KioskService.asmx/SaveAttendance";


        final ProgressDialog loading = ProgressDialog.show(TaskSelectionActivity.this, "Loading", "Please wait while loading data", false, false);
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

                                    RecognitionOptionActivity.attendance_id = jsonObject.getString("attendance_id");
                                    JSONObject jsonObjectResponse = jsonObject.getJSONObject("response"); //--added on 07-Aug-2021

                                    if (jsonObjectResponse.getString("status").contentEquals("true")) {
                                        save();
                                    } else {
                                        Toast.makeText(getApplicationContext(),"Internal error",Toast.LENGTH_LONG).show();
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

        RequestQueue requestQueue = Volley.newRequestQueue(TaskSelectionActivity.this);
        requestQueue.add(stringRequest);
    }
    //----added on 09-Aug-2021, to get attendenceid, code ends----
}
