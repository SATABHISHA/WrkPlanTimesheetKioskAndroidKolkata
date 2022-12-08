package org.arb.wrkplantimesheetkiosk.Admin;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import org.arb.wrkplantimesheetkiosk.Admin.EmployeeImageSettings.EmployeeImageSettingsActivity;
import org.arb.wrkplantimesheetkiosk.Admin.KioskUnitSettings.KioskUnitSettingsActivity;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;

public class AdminHomeActivity extends AppCompatActivity implements View.OnClickListener {
    TextView tv_logout;
//    LinearLayout ll_settings, ll_emp_img_settings; //---commenetd on 8th Dec as it is converted to relative layout
    ImageView img_unit_settings, img_emp_settings;
    RelativeLayout rl_logout, ll_settings, ll_emp_img_settings;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_home);

        tv_logout = findViewById(R.id.tv_logout);
        ll_settings = findViewById(R.id.ll_settings);
        img_unit_settings = findViewById(R.id.img_unit_settings);
        rl_logout = findViewById(R.id.rl_logout);

        ll_emp_img_settings = findViewById(R.id.ll_emp_img_settings);
        img_emp_settings = findViewById(R.id.img_emp_settings);

        tv_logout.setOnClickListener(this);

        ll_settings.setOnClickListener(this);
        img_unit_settings.setOnClickListener(this);

        ll_emp_img_settings.setOnClickListener(this);
        img_emp_settings.setOnClickListener(this);

        rl_logout.setOnClickListener(this);

//        Log.d("cordidtesting-=>",userSingletonModel.getCorpID());
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tv_logout:
                Intent intent = new Intent(this, LoginActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                break;
            case R.id.rl_logout:
                Intent intent_rl_logout = new Intent(this, LoginActivity.class);
                intent_rl_logout.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_rl_logout);
                break;
            case R.id.ll_settings:
                Intent intent_settings = new Intent(this, KioskUnitSettingsActivity.class);
                intent_settings.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_settings);
                break;
            case R.id.img_unit_settings:
                Intent intent_settings1 = new Intent(this, KioskUnitSettingsActivity.class);
                intent_settings1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_settings1);
                break;

            case R.id.ll_emp_img_settings:
                Intent intent_image_settings = new Intent(this, EmployeeImageSettingsActivity.class);
                intent_image_settings.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_image_settings);
                break;
            case R.id.img_emp_settings:
                Intent intent_image_settings1 = new Intent(this, EmployeeImageSettingsActivity.class);
                intent_image_settings1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent_image_settings1);
                break;
            default:
                break;
        }

    }

    @Override
    public void onBackPressed() {
//        super.onBackPressed();
    }
}
