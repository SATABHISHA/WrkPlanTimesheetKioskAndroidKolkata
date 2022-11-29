package org.arb.wrkplantimesheetkiosk.Home;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import org.arb.wrkplantimesheetkiosk.Admin.LoginActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.arb.wrkplantimesheetkiosk.Recognize.RecognizeHomeActivity;
import org.arb.wrkplantimesheetkiosk.Recognize.RecognizeHomeRealtimeActivity;

public class HomeActivity extends AppCompatActivity implements View.OnClickListener {

    TextView tv_rcognize;
    ImageView imgview_btn_profile;
    RelativeLayout rl_recognize;
    public static final int RequestPermissionCode = 1;
    SharedPreferences sharedPreferences;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    AlertDialog.Builder builder;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        tv_rcognize = findViewById(R.id.tv_rcognize);
        rl_recognize = findViewById(R.id.rl_recognize);
        imgview_btn_profile = findViewById(R.id.imgview_btn_profile);
        builder = new AlertDialog.Builder(this);
        tv_rcognize.setOnClickListener(this);
        imgview_btn_profile.setOnClickListener(this);
        rl_recognize.setOnClickListener(this);

        sharedPreferences = getApplication().getSharedPreferences("LoginDetails", Context.MODE_PRIVATE);
        EnableRuntimePermission();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.rl_recognize:
                if(!sharedPreferences.getString("CorpID", "").isEmpty()){
                    userSingletonModel.setCorpID(sharedPreferences.getString("CorpID", ""));
                    startActivity(new Intent(this, RecognizeHomeRealtimeActivity.class));
                }else{

                    builder.setMessage("The device is not ready yet! Please fill up all required information through admin login > Kiosk Unit Settings.")
                            .setCancelable(false)
                            .setNegativeButton("Ok", new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    //  Action for 'NO' Button
                                    Intent intent=new Intent(HomeActivity.this,HomeActivity.class);
                                    startActivity(intent);
                                    finish();
                                    dialog.cancel();

                                }
                            });
                    //Creating dialog box
                    AlertDialog alert_logout = builder.create();
                    //Setting the title manually
                    alert_logout.setTitle("Alert!");
                    alert_logout.show();
                }

                break;
            /*case R.id.tv_rcognize:
                if(!sharedPreferences.getString("CorpID", "").isEmpty()){
                  userSingletonModel.setCorpID(sharedPreferences.getString("CorpID", ""));
                    startActivity(new Intent(this, RecognizeHomeRealtimeActivity.class));
            }else{

                    builder.setMessage("The device is not ready yet! Please fill up all required information through admin login > Kiosk Unit Settings.")
                            .setCancelable(false)
                            .setNegativeButton("Ok", new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    //  Action for 'NO' Button
                                    Intent intent=new Intent(HomeActivity.this,HomeActivity.class);
                                    startActivity(intent);
                                    finish();
                                    dialog.cancel();

                                }
                            });
                    //Creating dialog box
                    AlertDialog alert_logout = builder.create();
                    //Setting the title manually
                    alert_logout.setTitle("Alert!");
                    alert_logout.show();
            }

                break;*/
            case R.id.imgview_btn_profile:
                startActivity(new Intent(this, LoginActivity.class));
                break;
            default:
                break;
        }
    }

    //--camera permission, starts----
    public void EnableRuntimePermission(){
        if (ActivityCompat.shouldShowRequestPermissionRationale(HomeActivity.this,
                Manifest.permission.CAMERA)) {
//            Toast.makeText(RecognizeHomeActivity.this,"CAMERA permission allows us to Access CAMERA app",     Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(HomeActivity.this,new String[]{
                    Manifest.permission.CAMERA}, RequestPermissionCode);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] result) {
        switch (requestCode) {
            case RequestPermissionCode:
                if (result.length > 0 && result[0] == PackageManager.PERMISSION_GRANTED) {
//                    Toast.makeText(HomeActivity.this, "Permission Granted, Now your application can access CAMERA.", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(HomeActivity.this, "Permission Canceled, Now your application cannot access CAMERA.", Toast.LENGTH_LONG).show();
                }
                break;
        }
    }
    //--camera permission, ends----
}