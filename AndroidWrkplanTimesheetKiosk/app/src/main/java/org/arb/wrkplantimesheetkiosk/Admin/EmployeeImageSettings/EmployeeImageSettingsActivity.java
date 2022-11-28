package org.arb.wrkplantimesheetkiosk.Admin.EmployeeImageSettings;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Adapter.EmployeeImageSettingsAdapter;
import org.arb.wrkplantimesheetkiosk.Adapter.TaskSelectionAdapter;
import org.arb.wrkplantimesheetkiosk.Admin.AdminHomeActivity;
import org.arb.wrkplantimesheetkiosk.Admin.KioskUnitSettings.KioskUnitSettingsActivity;
import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Config.ImageUtil;
import org.arb.wrkplantimesheetkiosk.Model.EmployeeImageSettingsModel;
import org.arb.wrkplantimesheetkiosk.Model.EmployeeTimesheetModel;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.arb.wrkplantimesheetkiosk.Recognize.RecognizeHomeActivity;
import org.arb.wrkplantimesheetkiosk.Recognize.RecognizeHomeRealtimeActivity;
import org.arb.wrkplantimesheetkiosk.Recognize.TaskSelectionActivity;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class EmployeeImageSettingsActivity extends AppCompatActivity implements View.OnClickListener {
    public static ArrayList<EmployeeImageSettingsModel> employeeImageSettingsModelArrayList = new ArrayList<>();
    public static ArrayList<EmployeeImageSettingsModel> filteredData = new ArrayList<>();
    RecyclerView recycler_view;
    LinearLayout ll_recycler;
    TextView tv_back;

    public static EmployeeImageSettingsAdapter employeeImageSettingsAdapter;
    public static final int RequestPermissionCode = 1;
    public static String base64String;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();

    EditText ed_search;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_employee_settings);

        ll_recycler = findViewById(R.id.ll_recycler);
        tv_back = findViewById(R.id.tv_back);
        ed_search = findViewById(R.id.ed_search);

        employeeImageSettingsAdapter = new EmployeeImageSettingsAdapter(this,filteredData);

        //==========Recycler code initializing and setting layoutManager starts======
        recycler_view = findViewById(R.id.recycler_view);
        recycler_view.setHasFixedSize(true);
        recycler_view.setLayoutManager(new LinearLayoutManager(this));
        //==========Recycler code initializing and setting layoutManager ends======

        loadData();

        EnableRuntimePermission();

        tv_back.setOnClickListener(this);

        //------code for filter data, starts(added on 16th march)
        ed_search.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                //after the change calling the method and passing the search input
//                filter(editable.toString());
                display_filtered_data(ed_search.getText().toString());
            }
        });
        //------code for filter data, ends
    }



    //---code to load data from api using volley, starts
    public void loadData(){

        if (!employeeImageSettingsModelArrayList.isEmpty()){
            employeeImageSettingsModelArrayList.clear();
        }
        String url = Config.BaseUrl + "KioskService.asmx/ListFaces";
        Log.d("urlEmployeeList-=>",url);


        final ProgressDialog loading = ProgressDialog.show(EmployeeImageSettingsActivity.this, "Loading", "Please wait while loading data", false, false);
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
                                    /*String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/
                                    JSONObject jsonObject_response = jsonObject.getJSONObject("response");

                                    if (jsonObject_response.getString("status").contentEquals("true")) {

                                        JSONArray jsonArray = jsonObject.getJSONArray("employees");
                                        for (int i = 0; i < jsonArray.length(); i++) {
                                            JSONObject jsonObject1 = jsonArray.getJSONObject(i);
                                            EmployeeImageSettingsModel employeeImageSettingsModel = new EmployeeImageSettingsModel();

                                            employeeImageSettingsModel.setEmployee_code(jsonObject1.getString("employee_code"));
                                            employeeImageSettingsModel.setId_person(jsonObject1.getString("id_person"));
                                            employeeImageSettingsModel.setName_first(jsonObject1.getString("name_first"));
                                            employeeImageSettingsModel.setName_last(jsonObject1.getString("name_last"));
                                            employeeImageSettingsModel.setEmployee_name(jsonObject1.getString("employee_name"));
                                            employeeImageSettingsModel.setAws_face_id(jsonObject1.getString("aws_face_id"));
                                            employeeImageSettingsModel.setAws_action(jsonObject1.getString("aws_action"));


                                            employeeImageSettingsModelArrayList.add(employeeImageSettingsModel);
                                        }

//                                recycler_view.setAdapter(new TaskSelectionAdapter(TaskSelectionActivity.this, employeeTimesheetModelArrayList));
//                                    recycler_view.setAdapter(employeeImageSettingsAdapter);
//                                    recycler_view.setAdapter(new EmployeeImageSettingsAdapter(EmployeeImageSettingsActivity.this,employeeImageSettingsModelArrayList)); //--commented on 16th April due search filter

                                        display_filtered_data(""); //--added on 16th April


                                        loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                    }else{
                                        loading.dismiss();
                                        /*Toast.makeText(getApplicationContext(),"false",Toast.LENGTH_LONG).show();
                                        Log.d("testfalse-=>","false executed");*/
                                        openPopupCreateGallery();
                                    }
                                }/*else{
                                    Toast.makeText(getApplicationContext(),"false",Toast.LENGTH_LONG).show();
                                    Log.d("testfalse-=>","false executed");
                                }*/
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
//                params.put("CorpId", "24");
                params.put("CorpId", userSingletonModel.getCorpID());
                /*params.put("UserId", String.valueOf(RecognizeHomeActivity.PersonId));
                params.put("deviceType", "1");
                params.put("EmpType", "MAIN");*/

                return params;
            }
        };

        /*RequestQueue requestQueue = Volley.newRequestQueue(EmployeeImageSettingsActivity.this);
        requestQueue.add(stringRequest);*/
        stringRequest.setRetryPolicy(new DefaultRetryPolicy(35000,
                DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        RequestQueue requestQueue = Volley.newRequestQueue(EmployeeImageSettingsActivity.this);
        requestQueue.add(stringRequest);
    }
    //---code to load data from api using volley, ends
    //===========code to filter data and display in list, code starts=======
    public void display_filtered_data(String employeename){
        if (!filteredData.isEmpty()){
            filteredData.clear();
        }
        if(employeeImageSettingsModelArrayList.size()>0) {
            for (int i = 0; i < employeeImageSettingsModelArrayList.size(); i++){
                String employeeName = employeeImageSettingsModelArrayList.get(i).getName_first()+" "+employeeImageSettingsModelArrayList.get(i).getName_last();
                if(employeeName.toLowerCase().trim().contains(employeename.toLowerCase())){

                    EmployeeImageSettingsModel employeeImageSettingsModel = new EmployeeImageSettingsModel();

                    employeeImageSettingsModel.setEmployee_code(employeeImageSettingsModelArrayList.get(i).getEmployee_code());
                    employeeImageSettingsModel.setId_person(employeeImageSettingsModelArrayList.get(i).getId_person());
                    employeeImageSettingsModel.setName_first(employeeImageSettingsModelArrayList.get(i).getName_first());
                    employeeImageSettingsModel.setName_last(employeeImageSettingsModelArrayList.get(i).getName_last());
                    employeeImageSettingsModel.setEmployee_name(employeeImageSettingsModelArrayList.get(i).getEmployee_name());
                    employeeImageSettingsModel.setAws_face_id(employeeImageSettingsModelArrayList.get(i).getAws_face_id());
                    employeeImageSettingsModel.setAws_action(employeeImageSettingsModelArrayList.get(i).getAws_action());
                    filteredData.add(employeeImageSettingsModel);

                }
            }
            recycler_view.setAdapter(new EmployeeImageSettingsAdapter(EmployeeImageSettingsActivity.this,filteredData));
        }/*else{
            ll_recycler.setVisibility(View.GONE);
            tv_nodata.setVisibility(View.VISIBLE);
            tv_nodata.setText(jsonObject1.getString("message"));
        }*/
    }
    //===========code to filter data and display in list, code ends=======
    //========Camera code starts=======
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 7 && resultCode == RESULT_OK) {
            Bitmap bitmap = (Bitmap) data.getExtras().get("data");
            base64String = ImageUtil.convert(bitmap);
//            Log.d("base64-=>",base64String);
            Log.d("name-=>",EmployeeImageSettingsAdapter.name);

//            recognize(base64String);
//            Log.d("base64-=>",base64String);
            EnrollImage(base64String);
        }
    }
    public void EnableRuntimePermission(){
        if (ActivityCompat.shouldShowRequestPermissionRationale(EmployeeImageSettingsActivity.this,
                Manifest.permission.CAMERA)) {
//            Toast.makeText(getApplicationContext(),"CAMERA permission allows us to Access CAMERA app",     Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(EmployeeImageSettingsActivity.this,new String[]{
                    Manifest.permission.CAMERA}, RequestPermissionCode);
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] result) {
        switch (requestCode) {
            case RequestPermissionCode:
                if (result.length > 0 && result[0] == PackageManager.PERMISSION_GRANTED) {
//                    Toast.makeText(EmployeeImageSettingsActivity.this, "Permission Granted, Now your application can access CAMERA.", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(EmployeeImageSettingsActivity.this, "Permission Canceled, Now your application cannot access CAMERA.", Toast.LENGTH_LONG).show();
                }
                break;
        }
    }
    //========Camera code ends=======

    //---code to enroll image, starts-----
    public void EnrollImage(String image_base64){
        String url = Config.BaseUrl + "KioskService.asmx/IndexFaces";


        final ProgressDialog loading = ProgressDialog.show(EmployeeImageSettingsActivity.this, "Loading", "Please wait while loading data", false, false);
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
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/

                                    if (jsonObject.getString("Status").contentEquals("true")){
                                        loadData();
                                        Log.d("result-=>",jsonObject.getString("Message"));
                                        /*finish();
                                        startActivity(getIntent());*/
                                    }else{
                                        loadData();
                                        /*finish();
                                        startActivity(getIntent());*/
                                        Log.d("result-=>",jsonObject.getString("Message"));
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
                params.put("EmployeeId", EmployeeImageSettingsAdapter.emp_id);
                params.put("ImageBase64", image_base64);
                /*params.put("UserId", String.valueOf(RecognizeHomeActivity.PersonId));
                params.put("deviceType", "1");
                params.put("EmpType", "MAIN");*/

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(EmployeeImageSettingsActivity.this);
        requestQueue.add(stringRequest);
    }
    //---code to enroll image, ends-----

    //-----code to openPopup and create gallery, starts-----
    public void openPopupCreateGallery(){

        //---custom dialog for create gallery, starts
        LayoutInflater li = LayoutInflater.from(EmployeeImageSettingsActivity.this);
        final View dialog = li.inflate(R.layout.dialog_creategallery, null);

        TextView tv_ok = dialog.findViewById(R.id.tv_ok);
        LinearLayout ll_ok = dialog.findViewById(R.id.ll_ok);


        AlertDialog.Builder alert = new AlertDialog.Builder(EmployeeImageSettingsActivity.this);
        alert.setView(dialog);
        alert.setCancelable(false);
        //Creating an alert dialog
        final AlertDialog alertDialog = alert.create();
        alertDialog.show();

        tv_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
                createGallery();
//                DeleteImage(position);
            }
        });

        /*ll_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });*/


        //---custom dialog for create gallery, ends
    }

    //-----function on gallery creation confirmation, starts----
    public void galleryCreationConfirmation(String message){
        //---custom dialog for create gallery, starts
        LayoutInflater li = LayoutInflater.from(EmployeeImageSettingsActivity.this);
        final View dialog = li.inflate(R.layout.dialog_gallery_creation_confirmation, null);

        TextView tv_ok = dialog.findViewById(R.id.tv_ok);
        TextView tv_body = dialog.findViewById(R.id.tv_body);

//        LinearLayout ll_ok = dialog.findViewById(R.id.ll_ok);

        tv_body.setText(message);

        AlertDialog.Builder alert = new AlertDialog.Builder(EmployeeImageSettingsActivity.this);
        alert.setView(dialog);
        alert.setCancelable(false);
        //Creating an alert dialog
        final AlertDialog alertDialog = alert.create();
        alertDialog.show();

        tv_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });
    }
    //-----function on gallery creation confirmation, ends----
    //--function to call api and create gallery, starts
    public void createGallery(){

        if (!employeeImageSettingsModelArrayList.isEmpty()){
            employeeImageSettingsModelArrayList.clear();
        }
        String url = Config.BaseUrl + "KioskService.asmx/CreateGallery";


        final ProgressDialog loading = ProgressDialog.show(EmployeeImageSettingsActivity.this, "Creating Gallery", "Please wait while creating Gallery", false, false);
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
                                    /*String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/
//                                    JSONObject jsonObject_response = jsonObject.getJSONObject("response");

                                    if (jsonObject.getString("Status").contentEquals("true")) {
                                        Toast.makeText(getApplicationContext(),jsonObject.getString("Message"),Toast.LENGTH_LONG).show();

                                        loading.dismiss();
                                        galleryCreationConfirmation("Employee Image Gallery created successfully");
                                        loadData();
                                    }else{
                                        loading.dismiss();
                                        galleryCreationConfirmation("Sorry! Error creating Employee Image Gallery. Please contact admin.");
                                        Toast.makeText(getApplicationContext(),"Unable to create Gallery",Toast.LENGTH_LONG).show();
//                                        Log.d("testfalse-=>","false executed");
                                    }
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
//                params.put("CorpId", "24");
                params.put("CorpId", userSingletonModel.getCorpID());

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(EmployeeImageSettingsActivity.this);
        requestQueue.add(stringRequest);
    }
    //--function to call api and create gallery, ends
    //-----code to openPopup and create gallery, ends-----

    @Override
    public void onBackPressed() {
//        super.onBackPressed();
        Intent intent = new Intent(EmployeeImageSettingsActivity.this, AdminHomeActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tv_back:
                Intent intent = new Intent(EmployeeImageSettingsActivity.this, AdminHomeActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                break;
            default:
                break;
        }
    }

}
