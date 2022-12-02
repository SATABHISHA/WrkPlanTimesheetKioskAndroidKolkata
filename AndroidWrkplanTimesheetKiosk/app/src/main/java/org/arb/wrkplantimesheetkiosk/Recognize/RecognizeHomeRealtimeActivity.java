package org.arb.wrkplantimesheetkiosk.Recognize;

import android.Manifest;
import android.animation.ObjectAnimator;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.hardware.Camera;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.arb.wrkplantimesheetkiosk.Config.Config;
import org.arb.wrkplantimesheetkiosk.Config.Temporary;
import org.arb.wrkplantimesheetkiosk.Home.HomeActivity;
import org.arb.wrkplantimesheetkiosk.Model.UserSingletonModel;
import org.arb.wrkplantimesheetkiosk.R;
import org.json.JSONObject;
import org.json.XML;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static android.Manifest.permission.CAMERA;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class RecognizeHomeRealtimeActivity extends AppCompatActivity implements SurfaceHolder.Callback, Camera.PictureCallback {
    private SurfaceHolder surfaceHolder;
    private Camera camera;

    public static final int REQUEST_CODE = 100;

    private SurfaceView surfaceView;

    private String[] neededPermissions = new String[]{CAMERA, WRITE_EXTERNAL_STORAGE};
    Camera.PictureCallback jpegCallback;
    private final Handler handler = new Handler();


    public static String base64String;

    public static String EmployeeCode, EmployeeName, Supervisor1, Supervisor2;
    public static Integer PersonId;
    //--added new
    boolean preview = false;
    Paint paint = new Paint();

    public static final int RequestPermissionCode = 1;


    UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
    View view_line;
    DisplayMetrics metrics = new DisplayMetrics(); //--added on 30th Aug
    public static int height = 0; //--added on 30th Aug



    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recognize_home_realtime);
        view_line = findViewById(R.id.view_line);
        view_line.setVisibility(View.VISIBLE);

        EnableRuntimePermission();

        //--added on 30th Aug, code starts----

        getWindowManager().getDefaultDisplay().getMetrics(metrics);
        height = metrics.heightPixels;
        Log.d("ScreenHeight-=>", String.valueOf(height));
        //----Using thread move line after evry x secs
        final Thread t = new Thread() {
            @Override
            public void run() {
                while (!isInterrupted()) {
                    try {
                        Thread.sleep(1);  //1000ms = 1 sec
//                        upload_data_delete_sqlite_data_test();
//                        new UploadData().execute();
//                        callStraightLine(linePosition);
                        callLine(linePosition);


                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        };

        t.start();
        /*do{

            i++;

        }while(i<=400);*/
        //--added on 30th Aug, code ends----

        surfaceView = findViewById(R.id.surfaceView);
        if (surfaceView != null) {
            boolean result = checkPermission();
            if (result) {
                setupSurfaceHolder();
//                captureImage();
            }
        }
//        Log.d("corpidtest-=>",userSingletonModel.getCorpID());

        //---temporary code, starts added on 13th may----
       /* Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.mypicsr);
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteStream);
        byte[] byteArray = byteStream.toByteArray();
        String baseString = Base64.encodeToString(byteArray,Base64.DEFAULT);
        recognize(baseString);*/
        //---temporary code, ends added on 13rh may----

       
    }

    Camera.FaceDetectionListener faceDetectionListener = new Camera.FaceDetectionListener() {
        @Override
        public void onFaceDetection(Camera.Face[] faces, Camera camera) {

            Log.d("detected-=>","face");
            if (faces.length > 0){

                Rect Boundary = faces[0].rect;
//                System.out.println(Boundary);

                tryDrawing(Boundary);

                //Just for the first one detected
                captureImage();
//                releaseCamera();
//                camera.stopPreview();

            }
        }
    };
    private boolean checkPermission() {
        int currentAPIVersion = Build.VERSION.SDK_INT;
        if (currentAPIVersion >= android.os.Build.VERSION_CODES.M) {
            ArrayList<String> permissionsNotGranted = new ArrayList<>();
            for (String permission : neededPermissions) {
                if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                    permissionsNotGranted.add(permission);
                }
            }
            if (permissionsNotGranted.size() > 0) {
                boolean shouldShowAlert = false;
                for (String permission : permissionsNotGranted) {
                    shouldShowAlert = ActivityCompat.shouldShowRequestPermissionRationale(this, permission);
                }
                if (shouldShowAlert) {
                    showPermissionAlert(permissionsNotGranted.toArray(new String[permissionsNotGranted.size()]));
                } else {
                    requestPermissions(permissionsNotGranted.toArray(new String[permissionsNotGranted.size()]));
                }
                return false;
            }
        }
        return true;
    }

    private void showPermissionAlert(final String[] permissions) {
//        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(this); //---commented on 2nd Dec, 2022
        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(this, R.style.Style_Dialog_Rounded_Corner); //---modified on 2nd Dec, 2022
        alertBuilder.setCancelable(true);
        alertBuilder.setTitle(R.string.permission_required);
        alertBuilder.setMessage(R.string.permission_message);
        alertBuilder.setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                requestPermissions(permissions);
            }
        });
        AlertDialog alert = alertBuilder.create();
        alert.show();
    }

    private void requestPermissions(String[] permissions) {
        ActivityCompat.requestPermissions(RecognizeHomeRealtimeActivity.this, permissions, REQUEST_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CODE:
                for (int result : grantResults) {
                    if (result == PackageManager.PERMISSION_DENIED) {
                        Toast.makeText(RecognizeHomeRealtimeActivity.this, R.string.permission_warning, Toast.LENGTH_LONG).show();
                        setViewVisibility(R.id.showPermissionMsg, View.VISIBLE);
                        return;
                    }
                }

                setupSurfaceHolder();
                break;
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }  //---commented

    private void setViewVisibility(int id, int visibility) {
        View view = findViewById(id);
        if (view != null) {
            view.setVisibility(visibility);
        }
    }

    private void setupSurfaceHolder() {
        setViewVisibility(R.id.surfaceView, View.VISIBLE);

        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
        /*captureImage();
        handler.post(timedTask);*/
//        setBtnClick();

        //--added
//        surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);


    }

    public void captureImage() {
        if (camera != null) {
//                    camera.takePicture(null, null, this);
            camera.takePicture(null, null, RecognizeHomeRealtimeActivity.this);
        }

    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        startCamera();
    }

    private void startCamera() {


//        camera = Camera.open();
     /*   camera = Camera.open(getFrontCameraId());
        camera.setDisplayOrientation(90);

        try {
            camera.setPreviewDisplay(surfaceHolder);
            camera.startPreview();
//            camera.startFaceDetection();

        } catch (IOException e) {
            e.printStackTrace();
        }*/ //commenting temporarily

        //--added new
        int cameraId = -1;
        int numberOfCameras = camera.getNumberOfCameras();

        for (int i = 0; i < numberOfCameras; i++) {
            Camera.CameraInfo info = new Camera.CameraInfo();
            Camera.getCameraInfo(i, info);

            if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                cameraId = i;
                break;
            }
        }

        camera = Camera.open(cameraId);
        camera.setDisplayOrientation(90);
        //---added on 15th march, code starts
        /*Camera.Parameters parameters = camera.getParameters();
        parameters.setPreviewSize(camera, mPreviewSize.height);
        camera.setParameters(parameters);*/
        //---added on 15th march, code ends

//        camera = Camera.open(getFrontCameraId());

        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                //Do something after 10000ms

                camera.setFaceDetectionListener(faceDetectionListener);
            }
        }, 4000); //---as per discussion, face will start detect after few sec(added handler on 15th march 21
//        camera.setFaceDetectionListener(faceDetectionListener);

        //--added on 30th Aug, code starts----
//        callStraightLine();
       /* ObjectAnimator animation = ObjectAnimator.ofFloat(view_line, "translationY", 100f);
        animation.setDuration(1000);
        animation.start();*/
        //--added on 30th Aug, code ends----
    }
    //--added on 30th Aug, code starts----
//    int height = Resources.getSystem().getDisplayMetrics().heightPixels;
//    DisplayMetrics displayMetrics = new DisplayMetrics();

//    int height = metrics.heightPixels;
    public static int linePosition = 0;
    Boolean flagLastYLimit = false;

    public void callLine(int i){
        view_line.setY(i);
        if(linePosition < height && flagLastYLimit == false) {
            linePosition = i + 1;
            flagLastYLimit = false;
            if(linePosition == height){
                flagLastYLimit = true;
            }
        }else if(linePosition <= height && flagLastYLimit == true){
            linePosition = i - 1;
            flagLastYLimit = true;
            if (linePosition == 0){
                flagLastYLimit = false;
            }
        }
    }

    //--added on 30th Aug, code ends----

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
//        resetCamera(); //temp commented
        //--new added
        if(preview){
            camera.stopFaceDetection();
            camera.stopPreview();
            preview = false;
        }

        if (camera != null){
            try {
                camera.setPreviewDisplay(surfaceHolder);
                camera.startPreview();
                camera.startFaceDetection();
                preview = true;
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    public void resetCamera() {
        if (surfaceHolder.getSurface() == null) {
            // Return if preview surface does not exist
            return;
        }

        if (camera != null) {
            // Stop if preview surface is already running.
            camera.stopPreview();
            try {
                // Set preview display
                camera.setPreviewDisplay(surfaceHolder);
            } catch (IOException e) {
                e.printStackTrace();
            }
            // Start the camera preview...
            camera.startPreview();
        }
    }


    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
//        releaseCamera(); //--temp commented

        //added new
        camera.stopFaceDetection();
        camera.stopPreview();
        camera.release();
        camera = null;
        preview = false;
    }

    private void releaseCamera() {
        if (camera != null) {
            camera.stopPreview();
            camera.release();
            camera = null;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onPictureTaken(byte[] bytes, Camera camera) {
//        saveImage(bytes);
        base64String = resizeBase64Image(Base64.encodeToString(bytes, Base64.NO_WRAP));
        Log.d("base64test-=>",base64String);

        view_line.setVisibility(View.INVISIBLE); //--added on 30th aug
        recognize(base64String);
//        resetCamera(); //--commented temp
        camera.stopPreview();

    }

    private void saveImage(byte[] bytes) {
        FileOutputStream outStream;
        try {
            String fileName = "TUTORIALWING_" + System.currentTimeMillis() + ".jpg";
            File file = new File(Environment.getExternalStorageDirectory(), fileName);
            outStream = new FileOutputStream(file);
            outStream.write(bytes);
            outStream.close();
            Toast.makeText(RecognizeHomeRealtimeActivity.this, "Picture Saved: " + fileName, Toast.LENGTH_LONG).show();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private int getFrontCameraId(){
        int camId = -1;
        int numberOfCameras = Camera.getNumberOfCameras();
        Camera.CameraInfo ci = new Camera.CameraInfo();

        for(int i = 0;i < numberOfCameras;i++){
            Camera.getCameraInfo(i,ci);
            if(ci.facing == Camera.CameraInfo.CAMERA_FACING_FRONT){
                camId = i;
            }
        }

        return camId;
    }

    //-----resize/compress image code, added on 12th march, starts------
    public String resizeBase64Image(String base64image){
        byte [] encodeByte=Base64.decode(base64image.getBytes(),Base64.DEFAULT);
        BitmapFactory.Options options=new BitmapFactory.Options();
        options.inPurgeable = true;
        Bitmap image = BitmapFactory.decodeByteArray(encodeByte, 0, encodeByte.length,options);


        if(image.getHeight() <= 400 && image.getWidth() <= 400){
            return base64image;
        }
        image = Bitmap.createScaledBitmap(image, 150, 150, true);

        ByteArrayOutputStream baos=new  ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.PNG,100, baos);

        byte [] b=baos.toByteArray();
        System.gc();
        return Base64.encodeToString(b, Base64.NO_WRAP);

    }
    //-----resize/compress image code, added on 12th march, ends------
    //---------------volley code for login starts-----------
    public void recognize(String imagebase64_string){

        //---added androidId on 18th nov
        String android_id = Settings.Secure.getString(getApplicationContext().getContentResolver(),
                Settings.Secure.ANDROID_ID);
        Log.d("AndroidIId-=>",android_id);

//        String loginURL ="http://220.225.40.151:9012/TimesheetService.asmx/ValidateTSheetLogin";
//        String loginURL = Config.BaseUrl + "ValidateTSheetLogin";
        String loginURL = Config.BaseUrl + "KioskService.asmx/RecognizeFace";


//        final ProgressDialog loading = ProgressDialog.show(RecognizeHomeRealtimeActivity.this, "Recognizing", "Please wait while recognizing face", false, false);
        //-------custom dialog code starts=========
        LayoutInflater li2 = LayoutInflater.from(this);
        View dialog = li2.inflate(R.layout.dialog_progressbar_image_processing, null);
        CoordinatorLayout crl = dialog.findViewById(R.id.crl);
        androidx.appcompat.app.AlertDialog.Builder alert = new androidx.appcompat.app.AlertDialog.Builder(this, R.style.Style_Dialog_Rounded_Corner);
        alert.setView(dialog);
        //Creating an alert dialog
        final androidx.appcompat.app.AlertDialog alertDialog = alert.create();
        Window window = alertDialog.getWindow();
        WindowManager.LayoutParams wlp = window.getAttributes();

        wlp.gravity = Gravity.BOTTOM;
        wlp.flags &= ~WindowManager.LayoutParams.FLAG_DIM_BEHIND;
        wlp.y = 100;
        window.setAttributes(wlp);
        alertDialog.show();
        //-------custom dialog code ends=========
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
                                            Log.d("EmployeeCode-=>",EmployeeCode);
                                            if(jsonObject.getString("Supervisor1").contentEquals("")){
                                                Supervisor1 = "Unassigned";
                                            }else {
                                                Supervisor1 = jsonObject.getString("Supervisor1");
                                            }
                                            if(jsonObject.getString("Supervisor1").contentEquals("")){
                                                Supervisor2 = "Unassigned";
                                            }else{
                                                Supervisor2 = jsonObject.getString("Supervisor2");
                                            }
                                            PersonId = jsonObject.getInt("PersonId");
                                            Intent intent = new Intent(RecognizeHomeRealtimeActivity.this, RecognitionOptionActivity.class);
                                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                                            startActivity(intent);
                                        } else {
//                                            Toast.makeText(getApplicationContext(), "Couldn't recognize", Toast.LENGTH_LONG).show();

                                            //---custom dialog for face detection, starts
                                            LayoutInflater li = LayoutInflater.from(RecognizeHomeRealtimeActivity.this);
                                            final View dialog = li.inflate(R.layout.dialog_recognize_home_realtime, null);

                                            TextView tv_try_again = dialog.findViewById(R.id.tv_try_again);
                                            TextView tv_cancel = dialog.findViewById(R.id.tv_cancel);


                                            AlertDialog.Builder alert = new AlertDialog.Builder(RecognizeHomeRealtimeActivity.this, R.style.Style_Dialog_Rounded_Corner);
                                            alert.setView(dialog);
                                            alert.setCancelable(false);
                                            //Creating an alert dialog
                                            final AlertDialog alertDialog = alert.create();
                                            alertDialog.show();

                                            tv_try_again.setOnClickListener(new View.OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    alertDialog.dismiss();
                                                    finish();
                                                    overridePendingTransition( 0, 0);
                                                    startActivity(getIntent());
                                                    overridePendingTransition( 0, 0);
                                                }
                                            });

                                            tv_cancel.setOnClickListener(new View.OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    alertDialog.dismiss();
                                                    Intent intent = new Intent(RecognizeHomeRealtimeActivity.this, HomeActivity.class);
                                                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                                                    startActivity(intent);
                                                }
                                            });


                                            //---custom dialog for face detection, ends
                                        }
                                    }else{
                                        Toast.makeText(getApplicationContext(), "Couldn't find any face", Toast.LENGTH_LONG).show();
                                    }

//                                    loading.dismiss();
                                    alertDialog.dismiss();
//                                    Toast.makeText(getApplicationContext(),xx.getString("content"),Toast.LENGTH_LONG).show();
                                }
                            }
                            Log.d("logintest",responseData);
                        }catch (Exception e){
                            e.printStackTrace();
//                            loading.dismiss();
                            alertDialog.dismiss();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
//                loading.dismiss();
                alertDialog.dismiss();


//                String message = "Could not connect server";
                String message = error.getMessage();
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

//                loading.dismiss();
                alertDialog.dismiss();


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

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(35000,
                DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        RequestQueue requestQueue = Volley.newRequestQueue(RecognizeHomeRealtimeActivity.this);
        requestQueue.add(stringRequest);
    }
    //---------------volley code for login ends-------------

    //--camera permission, starts----
    public void EnableRuntimePermission(){
        if (ActivityCompat.shouldShowRequestPermissionRationale(RecognizeHomeRealtimeActivity.this,
                Manifest.permission.CAMERA)) {
//            Toast.makeText(RecognizeHomeActivity.this,"CAMERA permission allows us to Access CAMERA app",     Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(RecognizeHomeRealtimeActivity.this,new String[]{
                    Manifest.permission.CAMERA}, RequestPermissionCode);
        }
    }

   /* @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] result) {
        switch (requestCode) {
            case RequestPermissionCode:
                if (result.length > 0 && result[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(RecognizeHomeRealtimeActivity.this, "Permission Granted, Now your application can access CAMERA.", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(RecognizeHomeRealtimeActivity.this, "Permission Canceled, Now your application cannot access CAMERA.", Toast.LENGTH_LONG).show();
                }
                break;
        }
    }*/
    //--camera permission, ends----



    //--newly added for trial, starts
    public void tryDrawing(Rect Boundary) {
        Log.d("test-=>", "Trying to draw...");

        Canvas canvas = surfaceHolder.lockCanvas();

        if (canvas == null) {

            Log.d("test1-=>", "Cannot draw onto the canvas as it's null");

        } else {

            drawMyStuff(canvas,Boundary);
            surfaceHolder.unlockCanvasAndPost(canvas);
        }
    }

    private void drawMyStuff(final Canvas canvas, Rect Boundary) {

        canvas.drawRect(Boundary.left, Boundary.top, Boundary.right, Boundary.bottom, paint);

        Log.d("test2", "Drawing...");

    }
//--newly added for trial, ends
}
