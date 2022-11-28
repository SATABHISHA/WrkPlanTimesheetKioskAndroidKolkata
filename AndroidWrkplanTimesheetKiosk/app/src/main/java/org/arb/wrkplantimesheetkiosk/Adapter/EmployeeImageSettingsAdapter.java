package org.arb.wrkplantimesheetkiosk.Adapter;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.hardware.Camera;
import android.os.Build;
import android.provider.MediaStore;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.RecyclerView;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Admin.EmployeeImageSettings.EmployeeImageSettingsActivity;
import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Model.EmployeeImageSettingsModel;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.XML;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static org.arb.wrkplantimesheetkiosk.Admin.EmployeeImageSettings.EmployeeImageSettingsActivity.employeeImageSettingsAdapter;

public class EmployeeImageSettingsAdapter extends RecyclerView.Adapter<EmployeeImageSettingsAdapter.MyViewHolder> {
    public LayoutInflater inflater;
    public static ArrayList<EmployeeImageSettingsModel> employeeImageSettingsModelArrayList;
    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    private Context context;
    public static String name, emp_id;


//    public static ProgressDialog loading;
//    public static TextView tv_download;


    public EmployeeImageSettingsAdapter(Context ctx, ArrayList<EmployeeImageSettingsModel> employeeImageSettingsModelArrayList){

        inflater = LayoutInflater.from(ctx);
        this.employeeImageSettingsModelArrayList = employeeImageSettingsModelArrayList;
    }

    @Override
    public EmployeeImageSettingsAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = inflater.inflate(R.layout.activity_employee_settings_row, parent, false);
        EmployeeImageSettingsAdapter.MyViewHolder holder = new EmployeeImageSettingsAdapter.MyViewHolder(view);
        context = parent.getContext();
        return holder;
    }

    @Override
    public void onBindViewHolder(EmployeeImageSettingsAdapter.MyViewHolder holder, int position) {
        holder.itemView.setTag(employeeImageSettingsModelArrayList.get(position));
//        holder.tv_name.setText(employeeImageSettingsModelArrayList.get(position).getEmployee_name());
        holder.tv_name.setText(employeeImageSettingsModelArrayList.get(position).getName_first()+" "+employeeImageSettingsModelArrayList.get(position).getName_last());

        /*holder.ll_enroll.setBackgroundResource(R.drawable.layout_enrollimage_border_remake);
        GradientDrawable drawable = ll_enroll.getBackground();*/
        if (employeeImageSettingsModelArrayList.get(position).getAws_action().contentEquals("enroll")){
            holder.tv_status.setText("No\nImage");
            holder.tv_status.setTextColor(Color.parseColor("#9A9A9A"));

            holder.tv_enroll_remove_image.setText("Enroll\nImage");
//            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#4f4f4f"));
            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#494949"));
//            holder.ll_enroll.setBackgroundColor(Color.parseColor("#D6D6D6"));
            holder.ll_enroll.setBackgroundResource(R.drawable.layout_enrollimage_border_remake_enroll);


        }else if (employeeImageSettingsModelArrayList.get(position).getAws_action().contentEquals("delete")){
            holder.tv_status.setText("Image\nEnrolled");
            holder.tv_status.setTextColor(Color.parseColor("#095CB0"));

            holder.tv_enroll_remove_image.setText("Remove \n Image");
//            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#8E0A02"));
            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#FFFFFF"));
//            holder.ll_enroll.setBackgroundColor(Color.parseColor("#FC362C"));
            holder.ll_enroll.setBackgroundResource(R.drawable.layout_enrollimage_border_remake_remove);
        }else {
            holder.tv_status.setText("Image\nEnrolled");
            holder.tv_status.setTextColor(Color.parseColor("#095CB0"));

            holder.tv_enroll_remove_image.setText("Remove\nImage");
//            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#8E0A02"));
            holder.tv_enroll_remove_image.setTextColor(Color.parseColor("#FFFFFF"));
//            holder.ll_enroll.setBackgroundColor(Color.parseColor("#FC362C"));
            holder.ll_enroll.setBackgroundResource(R.drawable.layout_enrollimage_border_remake_remove);
        }

//        holder.tv_enroll_remove_image.setGravity(View.TEXT_ALIGNMENT_CENTER);


    }

    @Override
    public int getItemCount() {
        return employeeImageSettingsModelArrayList.size();
    }


    public class MyViewHolder extends RecyclerView.ViewHolder {
        public TextView tv_name, tv_status, tv_enroll_remove_image;
        LinearLayout ll_enroll;

        public MyViewHolder(final View itemView) {
            super(itemView);
            final int position = getAdapterPosition();
            tv_name = itemView.findViewById(R.id.tv_name);
            tv_status = itemView.findViewById(R.id.tv_status);
            tv_enroll_remove_image = itemView.findViewById(R.id.tv_enroll_remove_image);
            ll_enroll = itemView.findViewById(R.id.ll_enroll);






            ll_enroll.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {


                    final int position = getAdapterPosition();

                    if (employeeImageSettingsModelArrayList.get(position).getAws_action().contentEquals("enroll")) {
                        LayoutInflater li = LayoutInflater.from(context);
                        final View dialog = li.inflate(R.layout.dialog_employee_image_alert, null);
                        final TextView tv_title = dialog.findViewById(R.id.tv_title);
                        final TextView tv_body = dialog.findViewById(R.id.tv_body);
                        final TextView tv_yes = dialog.findViewById(R.id.tv_yes);
                        final TextView tv_no = dialog.findViewById(R.id.tv_no);
                        final LinearLayout ll_yes = dialog.findViewById(R.id.ll_yes);
                        final LinearLayout ll_no = dialog.findViewById(R.id.ll_no);


                        tv_title.setText("Do you want to Enroll face image for "+employeeImageSettingsModelArrayList.get(position).getName_first()+" "+employeeImageSettingsModelArrayList.get(position).getName_last()+" ?");

                        String body = "1. Individual's head must be at center of the frame \n2. Individual should look directly at the camera \n3. No hair across individual's face or eyes \n4. Individual should not tilt head up/down or left/right \n5. Avoid dark background";
                        tv_body.setText(body);

                        AlertDialog.Builder alert = new AlertDialog.Builder(context);
                        alert.setView(dialog);
                        alert.setCancelable(false);
                        //Creating an alert dialog
                        final AlertDialog alertDialog = alert.create();
                        alertDialog.show();

                        ll_no.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                alertDialog.dismiss();
                            }
                        });
                        tv_no.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                alertDialog.dismiss();
                            }
                        });

                        ll_yes.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {


                                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//                            startActivityForResult(intent, 7); //commented for temp
                                //commented for temp
//                                intent.putExtra("android.intent.extras.CAMERA_FACING", android.hardware.Camera.CameraInfo.CAMERA_FACING_FRONT);
                                intent.putExtra("android.intent.extras.CAMERA_FACING", android.hardware.Camera.CameraInfo.CAMERA_FACING_FRONT);
                                intent.putExtra("android.intent.extras.LENS_FACING_FRONT", 1);
                                intent.putExtra("android.intent.extra.USE_FRONT_CAMERA", true);
                                // Samsung
                                intent.putExtra("camerafacing", "front");
                                intent.putExtra("previous_mode", "front");

                                // Huawei
                                intent.putExtra("default_camera", "1");
                                intent.putExtra("default_mode", "com.huawei.camera2.mode.photo.PhotoMode");
                                ((Activity) context).startActivityForResult(intent, 7);
//                                Toast.makeText(context.getApplicationContext(), employeeImageSettingsModelArrayList.get(position).getEmployee_name(), Toast.LENGTH_LONG).show();
                                alertDialog.dismiss();

                                name = employeeImageSettingsModelArrayList.get(position).getEmployee_name();
                                emp_id = employeeImageSettingsModelArrayList.get(position).getId_person();
//                            Log.d("base64-=>",base64String);




                            }
                        });
                        tv_yes.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {


                                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//                            startActivityForResult(intent, 7); //commented for temp
                                //commented for temp
//                                intent.putExtra("android.intent.extras.CAMERA_FACING", android.hardware.Camera.CameraInfo.CAMERA_FACING_FRONT);
                                intent.putExtra("android.intent.extras.CAMERA_FACING", android.hardware.Camera.CameraInfo.CAMERA_FACING_FRONT);
                                intent.putExtra("android.intent.extras.LENS_FACING_FRONT", 1);
                                intent.putExtra("android.intent.extra.USE_FRONT_CAMERA", true);

                                // Samsung
                                intent.putExtra("camerafacing", "front");
                                intent.putExtra("previous_mode", "front");

                                // Huawei
                                intent.putExtra("default_camera", "1");
                                intent.putExtra("default_mode", "com.huawei.camera2.mode.photo.PhotoMode");
                                ((Activity) context).startActivityForResult(intent, 7);
//                                Toast.makeText(context.getApplicationContext(), employeeImageSettingsModelArrayList.get(position).getEmployee_name(), Toast.LENGTH_LONG).show();
                                alertDialog.dismiss();

                                name = employeeImageSettingsModelArrayList.get(position).getEmployee_name();
                                emp_id = employeeImageSettingsModelArrayList.get(position).getId_person();
//                            Log.d("base64-=>",base64String);



                            }
                        });
                    }else if(employeeImageSettingsModelArrayList.get(position).getAws_action().contentEquals("delete")){
                        emp_id = employeeImageSettingsModelArrayList.get(position).getId_person();
//                        DeleteImage(position);
                        Log.d("position-=>",String.valueOf(position));

                        //---custom dialog for delete, starts
                        LayoutInflater li = LayoutInflater.from(context);
                        final View dialog = li.inflate(R.layout.dialog_employee_delete_alert, null);

                        TextView tv_ok = dialog.findViewById(R.id.tv_ok);
                        TextView tv_cancel = dialog.findViewById(R.id.tv_cancel);


                        AlertDialog.Builder alert = new AlertDialog.Builder(context);
                        alert.setView(dialog);
                        alert.setCancelable(false);
                        //Creating an alert dialog
                        final AlertDialog alertDialog = alert.create();
                        alertDialog.show();

                        tv_ok.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                DeleteImage(position);
                            }
                        });

                        tv_cancel.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                alertDialog.dismiss();
                            }
                        });


                        //---custom dialog for delete, ends
                    }
                }
            });



        }

        public void DeleteImage(int position){
            String url = Config.BaseUrl + "KioskService.asmx/DeleteFaces";


            final ProgressDialog loading = ProgressDialog.show(((Activity) context), "Loading", "Please wait while loading data", false, false);
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
//                                            loadData();
                                            employeeImageSettingsAdapter.notifyDataSetChanged();
//                                            Toast.makeText(context.getApplicationContext(),jsonObject.getString("Message"),Toast.LENGTH_LONG).show();  // commented n 18th feb
                                            Log.d("result-=>",jsonObject.getString("Message"));
                                            ((Activity)context).finish();
                                            ((Activity)context).startActivity(((Activity)context).getIntent());
                                        }else{
//                                            loadData();
                                            employeeImageSettingsAdapter.notifyDataSetChanged();
                                            Log.d("result-=>",jsonObject.getString("Message"));
                                            Toast.makeText(context.getApplicationContext(),jsonObject.getString("Message"),Toast.LENGTH_LONG).show();
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
                    Toast.makeText(context.getApplicationContext(),message,Toast.LENGTH_LONG).show();
                    Log.d("Volley Error-=>",error.toString());

                    loading.dismiss();


                }
            }) {
                @Override
                protected Map<String, String> getParams() throws AuthFailureError {
                    Map<String, String> params = new HashMap<>();
//                    params.put("CorpId", "arb-kol-dev");
                    params.put("CorpId", userSingletonModel.getCorpID());
                    params.put("EmployeeId", emp_id);
                    params.put("FaceId", employeeImageSettingsModelArrayList.get(position).getAws_face_id());
                /*params.put("UserId", String.valueOf(RecognizeHomeActivity.PersonId));
                params.put("deviceType", "1");
                params.put("EmpType", "MAIN");*/

                    return params;
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(context);
            requestQueue.add(stringRequest);
        }

    }
}
