package org.arb.wrkplantimesheetkiosk.Recognize;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class PunchOutBreakActivity extends AppCompatActivity {
    TextView tv_punch_status, tv_date, tv_time, tv_empname;
    ImageView img_status;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_punch_out_break);
        tv_punch_status = findViewById(R.id.tv_punch_status);
        img_status = findViewById(R.id.img_status);
        tv_date = findViewById(R.id.tv_date);
        tv_time = findViewById(R.id.tv_time);
        tv_empname = findViewById(R.id.tv_empname);

        tv_punch_status.setText(RecognitionOptionActivity.checkedInOut);
        tv_empname.setText(RecognizeHomeRealtimeActivity.EmployeeName);

        if(RecognitionOptionActivity.punch_out_break.contentEquals("out")){
            img_status.setBackgroundResource(R.drawable.goodbyevk1);
        }else{
//            img_status.setBackgroundResource(R.drawable.checkedin);
            img_status.setBackgroundResource(R.drawable.breakvk1);
        }

        //=========get current date and set curretnt date, code starts========
        Date c = Calendar.getInstance().getTime();
        System.out.println("Current time => " + c);

        SimpleDateFormat df = new SimpleDateFormat("dd-MMM-yyyy", Locale.getDefault());
        SimpleDateFormat df_time = new SimpleDateFormat("hh:mm a", Locale.getDefault());
        String formattedDate = df.format(c);
        String formattedTime = df_time.format(c);

        tv_date.setText(formattedDate);
        tv_time.setText(formattedTime);
        //=========get current date and set curretnt date, code ends========

        //---automatically redirect to another activity. code starts
        Handler handler=new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(PunchOutBreakActivity.this, HomeActivity.class);
                startActivity(intent);
            }
        },4000);
        //---automatically redirect to another activity. code ends
    }
}
