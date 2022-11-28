package org.arb.wrkplantimesheetkiosk.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import org.arb.wrkplantimesheetkiosk.Model.LeaveBalanceItemsModel;
import org.arb.wrkplantimesheetkiosk.R;

import java.util.ArrayList;

public class CustomLeaveBalanceAdapter extends BaseAdapter {
    ArrayList<LeaveBalanceItemsModel> arrayList = new ArrayList<>();
    Context context;
    public CustomLeaveBalanceAdapter(Context context, ArrayList<LeaveBalanceItemsModel> customLeaveBalanceAdapterArrayList){
        this.context = context;
        this.arrayList = customLeaveBalanceAdapterArrayList;
    }
    @Override
    public int getCount() {
        return arrayList.size();
    }

    @Override
    public Object getItem(int i) {
        return true;
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        TextView tv_personal, tv_personal_hrs, tv_vacation, tv_vacation_hrs;
        LayoutInflater layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        view = layoutInflater.inflate(R.layout.dialog_leave_balance_row,viewGroup,false);
        tv_personal = view.findViewById(R.id.tv_personal);
        tv_personal_hrs = view.findViewById(R.id.tv_personal_hrs);
       /* tv_vacation = view.findViewById(R.id.tv_vacation);
        tv_vacation_hrs = view.findViewById(R.id.tv_vacation_hrs);*/
        tv_personal.setText(arrayList.get(i).getPersonal());
        tv_personal_hrs.setText(arrayList.get(i).getPersonalHrs());
        /*tv_vacation.setText(arrayList.get(i).getVacation());
        tv_vacation_hrs.setText(arrayList.get(i).getVacationHrs());*/
        return view;
    }
}
