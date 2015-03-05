package codeanchor.com.codeanchortest;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.estimote.sdk.Beacon;

import java.util.ArrayList;

/**
 * @author Alec Rietman
 * @date January 22, 2015
 */
public class BeaconListAdapter extends BaseAdapter {

    ArrayList<Beacon> beacons;
    private LayoutInflater inflater;


    @Override
    public int getCount() {
        return beacons.size();
    }

    @Override
    public Object getItem(int position) {
        return beacons.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            inflater.inflate(R.layout.beacon_list, parent, false);
        }



        return convertView;
    }
}
