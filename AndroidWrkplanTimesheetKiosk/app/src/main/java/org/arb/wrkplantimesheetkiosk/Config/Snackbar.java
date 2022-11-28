package org.arb.wrkplantimesheetkiosk.Config;

import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

public class Snackbar {
  public Snackbar(String message, View view){
        int color = Color.parseColor("#ffffff");
        com.google.android.material.snackbar.Snackbar snackbar = com.google.android.material.snackbar.Snackbar.make(view, message, 4000);

        View sbView = snackbar.getView();
        TextView textView = (TextView) sbView.findViewById(com.google.android.material.R.id.snackbar_text);
        textView.setTextColor(color);
        snackbar.show();

    }
}
