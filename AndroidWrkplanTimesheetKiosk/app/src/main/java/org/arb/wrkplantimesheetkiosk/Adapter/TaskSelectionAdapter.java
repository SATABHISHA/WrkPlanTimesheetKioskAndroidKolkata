package org.arb.wrkplantimesheetkiosk.Adapter;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.text.Html;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.RecyclerView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Model.EmployeeTimesheetModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.arb.wrkplantimesheetkiosk.Recognize.RecognitionOptionActivity;
import org.arb.wrkplantimesheetkiosk.Recognize.TaskSelectionActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

public class TaskSelectionAdapter extends RecyclerView.Adapter<TaskSelectionAdapter.MyViewHolder> {
    public LayoutInflater inflater;
    public static ArrayList<EmployeeTimesheetModel> employeeTimesheetModelArrayList;
    private Context context;
    private int lastCheckedPosition = -1;

//    public static String od_request_id = "";
//    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();

//    public static ProgressDialog loading;
//    public static TextView tv_download;


    public TaskSelectionAdapter(Context ctx, ArrayList<EmployeeTimesheetModel> employeeTimesheetModelArrayList){

        inflater = LayoutInflater.from(ctx);
        this.employeeTimesheetModelArrayList = employeeTimesheetModelArrayList;
    }
    @Override
    public TaskSelectionAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = inflater.inflate(R.layout.activity_task_selection_row, parent, false);
        TaskSelectionAdapter.MyViewHolder holder = new TaskSelectionAdapter.MyViewHolder(view);
        context = parent.getContext();
        return holder;
    }
    public static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();

        long factor = (long) Math.pow(10, places);
        value = value * factor;
        long tmp = Math.round(value);
        return (double) tmp / factor;
    }

    @Override
    public void onBindViewHolder(TaskSelectionAdapter.MyViewHolder holder, int position) {
        int updated_position = holder.getAdapterPosition();
        holder.itemView.setTag(employeeTimesheetModelArrayList.get(updated_position));
        if(employeeTimesheetModelArrayList.get(updated_position).getDefaultTaskYn() == 1){
            String text1 = getColoredSpanned(employeeTimesheetModelArrayList.get(updated_position).getAccountCode(), "#a7a7a7");
            String text2 = getColoredSpanned("(Default)","#FF0000");

//            holder.tv_account_code.setText(employeeTimesheetModelArrayList.get(position).getAccountCode()+ "(Default)");
//            holder.tv_account_code.setText(employeeTimesheetModelArrayList.get(position).getAccountCode()+" "+ Html.fromHtml(text));
            holder.tv_account_code.setText(Html.fromHtml(text1+" "+text2));
            lastCheckedPosition = updated_position;
        }else {
            holder.tv_account_code.setText(employeeTimesheetModelArrayList.get(updated_position).getAccountCode());
        }

        holder.tv_contract.setText(employeeTimesheetModelArrayList.get(updated_position).getContract());
        holder.tv_contract_type.setText(employeeTimesheetModelArrayList.get(updated_position).getLaborCategory());
        holder.tv_hrs.setText(employeeTimesheetModelArrayList.get(position).getHour());
//        holder.tv_hrs.setText(String.format("%.2f", Double.valueOf(employeeTimesheetModelArrayList.get(position).getHour())));
//        holder.tv_hrs.setText(String.valueOf(round(Double.valueOf(employeeTimesheetModelArrayList.get(position).getHour()),2)));


        //--added on 12th feb, starts
        if(employeeTimesheetModelArrayList.get(updated_position).getTempDefault() == 1){
           lastCheckedPosition = updated_position;
        }else{
            lastCheckedPosition = -1;
        }
        //--added on 12th feb, ends

        holder.radio_btn.setChecked(updated_position == lastCheckedPosition);
        if (lastCheckedPosition == updated_position) {
            holder.radio_btn.setChecked(true);
        }else{
            holder.radio_btn.setChecked(false);
        }



    }

    @Override
    public int getItemCount() {
        return employeeTimesheetModelArrayList.size();
    }


    public class MyViewHolder extends RecyclerView.ViewHolder {
        public TextView tv_account_code, tv_contract, tv_contract_type, tv_hrs;
        RadioButton radio_btn;
        RelativeLayout relative_layout;
        ImageView img_demo;



        public MyViewHolder(final View itemView) {
            super(itemView);
            tv_account_code = itemView.findViewById(R.id.tv_account_code);
            tv_contract = itemView.findViewById(R.id.tv_contract);
            tv_contract_type = itemView.findViewById(R.id.tv_contract_type);
            tv_hrs = itemView.findViewById(R.id.tv_hrs);
            relative_layout = itemView.findViewById(R.id.relative_layout);
            radio_btn = itemView.findViewById(R.id.radio_btn);

            relative_layout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    final int position = getAdapterPosition();
                    for(int i=0; i<employeeTimesheetModelArrayList.size(); i++){
                        employeeTimesheetModelArrayList.get(i).setTempDefault(0);
                        Log.d("defaulttest-=>",employeeTimesheetModelArrayList.get(position).getTempDefault().toString());
                    }
                    employeeTimesheetModelArrayList.get(position).setTempDefault(1);
                    Log.d("test-=>",employeeTimesheetModelArrayList.get(position).getTempDefault().toString());
//                    notifyDataSetChanged();


                    lastCheckedPosition = getAdapterPosition();
                    notifyItemRangeChanged(0, employeeTimesheetModelArrayList.size());

//                    TaskSelectionActivity.taskSelectionAdapter.notifyDataSetChanged();
                   /* OutdoorListActivity.new_create_yn = 0;
                    od_request_id = outDoorListModelArrayList.get(position).getOd_request_id();
                    Intent i = new Intent(context, OutDoorRequestActivity.class);
                    context.startActivity(i);*/

                    TaskSelectionActivity.ContractID = employeeTimesheetModelArrayList.get(position).getContractID();
                    TaskSelectionActivity.TaskId = employeeTimesheetModelArrayList.get(position).getTaskID();
                    TaskSelectionActivity.LaborCatId = employeeTimesheetModelArrayList.get(position).getLaborCategoryID();
                    TaskSelectionActivity.CostTypeId = employeeTimesheetModelArrayList.get(position).getCostTypeID();
                    TaskSelectionActivity.ACSuffix = employeeTimesheetModelArrayList.get(position).getACSuffix();
                    RecognitionOptionActivity.EmployeeAssignmentID = employeeTimesheetModelArrayList.get(position).getEmployeeAssignmentID();

                    TaskSelectionActivity.taskSelectionAdapter.notifyDataSetChanged(); //--added on 12th feb
                }
            });
            radio_btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    lastCheckedPosition = getAdapterPosition();

                    //--added on 12th feb, starts
                    final int position = getAdapterPosition();
                    for(int i=0; i<employeeTimesheetModelArrayList.size(); i++){
                        employeeTimesheetModelArrayList.get(i).setTempDefault(0);
                        Log.d("defaulttest-=>",employeeTimesheetModelArrayList.get(position).getTempDefault().toString());
                    }
                    employeeTimesheetModelArrayList.get(position).setTempDefault(1);
                    //--added on 12th feb, ends

                    notifyItemRangeChanged(0, employeeTimesheetModelArrayList.size());
                    TaskSelectionActivity.ContractID = employeeTimesheetModelArrayList.get(lastCheckedPosition).getContractID();
                    TaskSelectionActivity.TaskId = employeeTimesheetModelArrayList.get(lastCheckedPosition).getTaskID();
                    TaskSelectionActivity.LaborCatId = employeeTimesheetModelArrayList.get(lastCheckedPosition).getLaborCategoryID();
                    TaskSelectionActivity.CostTypeId = employeeTimesheetModelArrayList.get(lastCheckedPosition).getCostTypeID();
                    TaskSelectionActivity.ACSuffix = employeeTimesheetModelArrayList.get(lastCheckedPosition).getACSuffix();
                    RecognitionOptionActivity.EmployeeAssignmentID = employeeTimesheetModelArrayList.get(position).getEmployeeAssignmentID();

                    TaskSelectionActivity.taskSelectionAdapter.notifyDataSetChanged(); //--added on 12th feb
                }
            });

        }


    }

    private String getColoredSpanned(String text, String color) {
        String input = "<font color=" + color + ">" + text + "</font>";
        return input;
    }

}
