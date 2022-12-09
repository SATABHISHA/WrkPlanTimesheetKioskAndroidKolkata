package org.arb.wrkplantimesheetkiosk.Admin;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.Settings;
import android.text.InputType;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Config.Snackbar;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;


public class LoginActivity extends AppCompatActivity implements View.OnClickListener {
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    EditText edtCorpId,edtUsername,edtPassword;
    LinearLayout btnLogin;
    TextView tv_login;
    SharedPreferences sharedPreferences;
    ImageButton imgbtn_home, img_btn_pswd_invisible, img_btn_pswd_visible;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        edtCorpId = findViewById(R.id.activity_login_edt_corp_ID);
        edtUsername = findViewById(R.id.activity_login_edt_username);
        edtPassword = findViewById(R.id.activity_login_edt_password);
        imgbtn_home = findViewById(R.id.imgbtn_home);
        img_btn_pswd_visible = findViewById(R.id.img_btn_pswd_visible);
        img_btn_pswd_invisible = findViewById(R.id.img_btn_pswd_invisible);

        btnLogin = findViewById(R.id.activity_login_btn_login);
        tv_login = findViewById(R.id.tv_login);

        sharedPreferences = getApplication().getSharedPreferences("LoginDetails", Context.MODE_PRIVATE);
        //=========to check sharedpref and autofill corpid, code starts, added on 12th june=============
        String autofillCorpId = sharedPreferences.getString("CorpIdForUserAutofill","");
        if(autofillCorpId != ""){
            edtCorpId.setText(sharedPreferences.getString("CorpIdForUserAutofill",""));
        }
        //=========to check sharedpref and autofill corpid, code ends, added on 12th june=============

        btnLogin.setOnClickListener(this);
        imgbtn_home.setOnClickListener(this);
        tv_login.setOnClickListener(this);
        img_btn_pswd_invisible.setOnClickListener(this);
        img_btn_pswd_visible.setOnClickListener(this);
    }


    //========following function is to resign keyboard on touching anywhere in the screen, starts
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (getCurrentFocus() != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
        return super.dispatchTouchEvent(ev);
    }
    //========following function is to resign keyboard on touching anywhere in the screen, ends

    //---------------volley code for login starts-----------
    public void login(){

        //---added androidId on 18th nov
        String android_id = Settings.Secure.getString(getApplicationContext().getContentResolver(),
                Settings.Secure.ANDROID_ID);
        Log.d("AndroidIId-=>",android_id);

//        String loginURL ="http://220.225.40.151:9012/TimesheetService.asmx/ValidateTSheetLogin";
//        String loginURL = Config.BaseUrl + "ValidateTSheetLogin";
        String loginURL = Config.BaseUrl + "KioskService.asmx/ValidateTSheetKioskAdminLogin";


        final ProgressDialog loading = ProgressDialog.show(LoginActivity.this, "Authenticating", "Please wait while logging", false, false);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, loginURL,
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
                                    String status = jsonObject.getString("status");
                                    if(status.equalsIgnoreCase("true")){
                                        JSONArray jsonArray = jsonObject.getJSONArray("UserLogin");
                                        for(int i=0; i<=jsonArray.length(); i++){
                                            JSONObject jsonObject1 = jsonArray.getJSONObject(i);
                                            String companyName = jsonObject1.getString("CompanyName");
                                            //--------setting the value in sigleton class variables code starts----------
                                            userSingletonModel.setUserID(jsonObject1.getString("UserID"));
                                            userSingletonModel.setUserName(jsonObject1.getString("UserName"));
                                            userSingletonModel.setCompID(jsonObject1.getString("CompID"));
                                            // user.setCompanyID(jobj.getString("CompanyID"));
                                            userSingletonModel.setCorpID(jsonObject1.getString("CorpID"));
                                            userSingletonModel.setCompanyName(jsonObject1.getString("CompanyName"));
                                            userSingletonModel.setSupervisorId(jsonObject1.getString("SupervisorId"));
                                            userSingletonModel.setUserRole(jsonObject1.getString("UserRole"));
                                            userSingletonModel.setAdminYN(jsonObject1.getString("AdminYN"));
                                            userSingletonModel.setPayableClerkYN(jsonObject1.getString("PayableClerkYN"));
                                            userSingletonModel.setSupervisorYN(jsonObject1.getString("SupervisorYN"));
                                            userSingletonModel.setPurchaseYN(jsonObject1.getString("PurchaseYN"));
                                            userSingletonModel.setPayrollClerkYN(jsonObject1.getString("PayrollClerkYN"));
                                            userSingletonModel.setEmpName(jsonObject1.getString("EmpName"));
                                            userSingletonModel.setUserType(jsonObject1.getString("UserType"));
                                            userSingletonModel.setEmailId(jsonObject1.getString("EmailId"));
                                            userSingletonModel.setPwdSetterId(jsonObject1.getString("PwdSetterId"));
                                            userSingletonModel.setFinYearID(jsonObject1.getString("FinYearID"));
                                            userSingletonModel.setMsg(jsonObject1.getString("Msg"));

                                            //------for sending email variables initialization, code starts---
                                            userSingletonModel.setEmailServer(jsonObject1.getString("EmailServer"));
                                            userSingletonModel.setEmailServerPort(jsonObject1.getString("EmailServerPort"));
                                            userSingletonModel.setEmailSendingUsername(jsonObject1.getString("EmailUsername"));
                                            userSingletonModel.setEmailPassword(jsonObject1.getString("EmailPassword"));
                                            userSingletonModel.setEmailHostAddress(jsonObject1.getString("EmailHostAddress"));

                                            //------for sending email variables initialization, code ends---
                                            //--------setting the value in sigleton class variables code ends----------
                                            //======================storing the value to shared preference for onetime login code starts=============
//                                            if (chkSignedIn.isChecked()){ //as checkbox is not req for kiosk
                                                sharedPreferences = getApplication().getSharedPreferences("LoginDetails", Context.MODE_PRIVATE);
                                                SharedPreferences.Editor editor = sharedPreferences.edit();
                                                editor.putString("UserID", userSingletonModel.getUserID());
                                                editor.putString("UserName", userSingletonModel.getUserName());
                                                editor.putString("CompID", userSingletonModel.getCompID());
                                                editor.putString("CorpID", userSingletonModel.getCorpID());
                                                editor.putString("CompanyName", userSingletonModel.getCompanyName());
                                                editor.putString("SupervisorId", userSingletonModel.getSupervisorId());
                                                editor.putString("UserRole", userSingletonModel.getUserRole());
                                                editor.putString("AdminYN", userSingletonModel.getAdminYN());
                                                editor.putString("PayableClerkYN", userSingletonModel.getPayableClerkYN());
                                                editor.putString("SupervisorYN", userSingletonModel.getSupervisorYN());
                                                editor.putString("PurchaseYN", userSingletonModel.getPurchaseYN());
                                                editor.putString("PayrollClerkYN", userSingletonModel.getPayrollClerkYN());
                                                editor.putString("EmpName", userSingletonModel.getEmpName());
                                                editor.putString("UserType", userSingletonModel.getUserType());
                                                editor.putString("EmailId", userSingletonModel.getEmailId());
                                                editor.putString("PwdSetterId", userSingletonModel.getPwdSetterId());
                                                editor.putString("FinYearID", userSingletonModel.getFinYearID());
                                                editor.putString("Msg", userSingletonModel.getMsg());

                                                //------for sending email variables initialization, code starts---
                                                editor.putString("EmailServer", userSingletonModel.getEmailServer());
                                                editor.putString("EmailServerPort", userSingletonModel.getEmailServerPort());
                                                editor.putString("EmailUsername", userSingletonModel.getEmailSendingUsername());
                                                editor.putString("EmailPassword", userSingletonModel.getEmailPassword());
                                                editor.putString("EmailHostAddress", userSingletonModel.getEmailHostAddress());
                                                //------for sending email variables initialization, code ends---
                                                editor.commit();
                                                //======================storing the value to shared preference for onetime login code ends=============
//                                            } //as checkbox is not req for kiosk
                                            Intent intent = new Intent(LoginActivity.this, AdminHomeActivity.class);
                                            startActivity(intent);
                                            loading.dismiss();
                                            //-----------storing the value og corp-id from edittext, added on 12th june, starts============
                                            sharedPreferences = getApplication().getSharedPreferences("LoginDetails", Context.MODE_PRIVATE);
//                                            SharedPreferences.Editor editor = sharedPreferences.edit(); //--it is not req anymore in kiosk
                                            editor.putString("CorpIdForUserAutofill", edtCorpId.getText().toString());
                                            editor.commit();
                                            //-----------storing the value og corp-id from edittext, added on 12th june, ends============
                                            finish();

                                        }

                                    }else if(status.equalsIgnoreCase("false")){
                                        loading.dismiss();
//                                        String message = "Invalid Login Credential";
                                        String message = jsonObject.getString("message");
                                       /* int color = Color.parseColor("#ffffff");
                                        Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, Snackbar.LENGTH_LONG);

                                        View sbView = snackbar.getView();
                                        TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                                        textView.setTextColor(color);
                                        snackbar.show();*/

                                        View v = findViewById(R.id.relativeLayout);
//                                        new org.arb.gst.config.Snackbar(message,v);
                                        new Snackbar(message,v);

                                        btnLogin.setEnabled(true);
                                        btnLogin.setClickable(true);
                                        btnLogin.setAlpha(1.0f);
                                    }
                                    Log.d("statusTest",status);
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }
                            Log.d("logintest",responseData);
                        }catch (Exception e){
                            e.printStackTrace();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                loading.dismiss();
                btnLogin.setEnabled(true);
                btnLogin.setClickable(true);
                btnLogin.setAlpha(1.0f);

                String message = "Could not connect server";
               /* int color = Color.parseColor("#ffffff");
                Snackbar snackbar = Snackbar.make(findViewById(R.id.relativeLayout), message, 4000);

                View sbView = snackbar.getView();
                TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
                textView.setTextColor(color);
                snackbar.show();*/

                View v = findViewById(R.id.relativeLayout);
//                new org.arb.gst.config.Snackbar(message,v);
                new Snackbar(message,v);
                Log.d("Volley Error-=>",error.toString());


            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
                params.put("CorpID", edtCorpId.getText().toString());
                params.put("UserName", edtUsername.getText().toString());
                params.put("Password",edtPassword.getText().toString());
                params.put("DeviceID",android_id);
                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(LoginActivity.this);
        requestQueue.add(stringRequest);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.img_btn_pswd_visible:
                edtPassword.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_NORMAL);
                img_btn_pswd_visible.setVisibility(View.INVISIBLE);
                img_btn_pswd_invisible.setVisibility(View.VISIBLE);
                break;
            case R.id.img_btn_pswd_invisible:
                edtPassword.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
                img_btn_pswd_visible.setVisibility(View.VISIBLE);
                img_btn_pswd_invisible.setVisibility(View.INVISIBLE);
                break;

            case R.id.activity_login_btn_login:
                if(edtCorpId.getText().toString().isEmpty() || edtUsername.getText().toString().isEmpty() || edtPassword.getText().toString().isEmpty()) {
                    if (edtCorpId.getText().toString().isEmpty()) {
                        View v1 = findViewById(R.id.relativeLayout);
//                                        new org.arb.gst.config.Snackbar(message,v);
                        new Snackbar("Userid is required",v1);

                        return;
                    }
                    if (edtUsername.getText().toString().isEmpty()) {
                        View v2 = findViewById(R.id.relativeLayout);
//                                        new org.arb.gst.config.Snackbar(message,v);
                        new Snackbar("Username is required",v2);

                        return;
                    }
                    if (edtPassword.getText().toString().isEmpty()) {
                        View v3 = findViewById(R.id.relativeLayout);
//                                        new org.arb.gst.config.Snackbar(message,v);
                        new Snackbar("Password  is required",v3);
                        return;
                    }
                }else {


                    btnLogin.setEnabled(false);
                    btnLogin.setClickable(false);
                    btnLogin.setAlpha(0.4f);

                    login();
                }
                break;
            case R.id.tv_login:
//                login();

                if(edtCorpId.getText().toString().isEmpty() || edtUsername.getText().toString().isEmpty() || edtPassword.getText().toString().isEmpty()) {
                    if (edtCorpId.getText().toString().isEmpty()) {
                        View v1 = findViewById(R.id.relativeLayout);
                        new Snackbar("Userid is required",v1);

                        return;
                    }
                    if (edtUsername.getText().toString().isEmpty()) {
                        View v2 = findViewById(R.id.relativeLayout);
                        new Snackbar("Username is required",v2);

                        return;
                    }
                    if (edtPassword.getText().toString().isEmpty()) {
                        View v3 = findViewById(R.id.relativeLayout);
                        new Snackbar("Password  is required",v3);
                        return;
                    }
                }else {


                    btnLogin.setEnabled(false);
                    btnLogin.setClickable(false);
                    btnLogin.setAlpha(0.4f);

                    login();
                }
                break;
            case R.id.imgbtn_home:
                Intent intent = new Intent(this, HomeActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                break;
        }
    }
    //---------------volley code for login ends-------------
}
