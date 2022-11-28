package org.arb.wrkplantimesheetkiosk.Recognize;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Config.ImageUtil;
import org.arb.wrkplantimesheetkiosk.Config.Temporary;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class RecognizeHomeActivity extends AppCompatActivity implements View.OnClickListener {
    TextView tv_takephoto;
    ImageView img;
    public static final int RequestPermissionCode = 1;
    public static String base64String;

    public static String EmployeeCode, EmployeeName, Supervisor1, Supervisor2;
    public static Integer PersonId;

    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rcognize_home);
        tv_takephoto = findViewById(R.id.tv_takephoto);
        img = findViewById(R.id.img);
//        img.setBackgroundResource(R.drawable.ab);
        tv_takephoto.setOnClickListener(this);

        EnableRuntimePermission();
        Log.d("corpidtest-=>",userSingletonModel.getCorpID());
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tv_takephoto:
                Intent intent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
                intent.putExtra("android.intent.extras.CAMERA_FACING", 1);
                startActivityForResult(intent, 7); //commented for temp


                recognize(Temporary.imagetemp); //for temp

                //---for testing purpose in emulator
               /* EmployeeName = "Bhattacharya, Achintya";
                EmployeeCode = "25";
                Supervisor1 = "a, b ";
                Supervisor2 = " ";
                PersonId = 33;
                Intent intent = new Intent(RecognizeHomeActivity.this, RecognitionOptionActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);*/
                break;
            default:
                break;
        }
    }

    //========Camera code starts=======
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 7 && resultCode == RESULT_OK) {
            Bitmap bitmap = (Bitmap) data.getExtras().get("data");
            img.setImageBitmap(bitmap);
            base64String = ImageUtil.convert(bitmap);
            Log.d("base64-=>",base64String);

            recognize(base64String);
//            Log.d("base64-=>",base64String);
        }
    }
    public void EnableRuntimePermission(){
        if (ActivityCompat.shouldShowRequestPermissionRationale(RecognizeHomeActivity.this,
                Manifest.permission.CAMERA)) {
//            Toast.makeText(RecognizeHomeActivity.this,"CAMERA permission allows us to Access CAMERA app",     Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(RecognizeHomeActivity.this,new String[]{
                    Manifest.permission.CAMERA}, RequestPermissionCode);
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] result) {
        switch (requestCode) {
            case RequestPermissionCode:
                if (result.length > 0 && result[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(RecognizeHomeActivity.this, "Permission Granted, Now your application can access CAMERA.", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(RecognizeHomeActivity.this, "Permission Canceled, Now your application cannot access CAMERA.", Toast.LENGTH_LONG).show();
                }
                break;
        }
    }
    //========Camera code ends=======

    //---------------volley code for login starts-----------
    public void recognize(String imagebase64_string){

        //---added androidId on 18th nov
        String android_id = Settings.Secure.getString(getApplicationContext().getContentResolver(),
                Settings.Secure.ANDROID_ID);
        Log.d("AndroidIId-=>",android_id);

//        String loginURL ="http://220.225.40.151:9012/TimesheetService.asmx/ValidateTSheetLogin";
//        String loginURL = Config.BaseUrl + "ValidateTSheetLogin";
        String loginURL = Config.BaseUrl + "KioskService.asmx/RecognizeFace";


        final ProgressDialog loading = ProgressDialog.show(RecognizeHomeActivity.this, "Recognizing", "Please wait while recognizing face", false, false);
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
                                   /* String status = jsonObject.getString("status");

                                    Log.d("statusTest",status);*/
                                    if(jsonObject.has("PersonId")) {
                                        if (jsonObject.getInt("PersonId") > 0) {
                                            EmployeeName = jsonObject.getString("EmployeeName");
                                            EmployeeCode = jsonObject.getString("EmployeeCode");
                                            Supervisor1 = jsonObject.getString("Supervisor1");
                                            Supervisor2 = jsonObject.getString("Supervisor2");
                                            PersonId = jsonObject.getInt("PersonId");
                                            Intent intent = new Intent(RecognizeHomeActivity.this, RecognitionOptionActivity.class);
                                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                                            startActivity(intent);
                                        } else {
                                            Toast.makeText(getApplicationContext(), "Couldn't recognize", Toast.LENGTH_LONG).show();
                                        }
                                    }else{
                                        Toast.makeText(getApplicationContext(), "Couldn't find any face", Toast.LENGTH_LONG).show();
                                    }

                                    loading.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }
                            Log.d("logintest",responseData);
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
                params.put("ImageBase64", imagebase64_string);

                return params;
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(RecognizeHomeActivity.this);
        requestQueue.add(stringRequest);
    }
    //---------------volley code for login ends-------------
}
