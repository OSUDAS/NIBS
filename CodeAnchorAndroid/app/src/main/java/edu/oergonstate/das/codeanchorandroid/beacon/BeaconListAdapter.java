package edu.oergonstate.das.codeanchorandroid.beacon;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;

import edu.oergonstate.das.codeanchorandroid.R;

/**
 * A custom Adapter to handle the list of beacons in the Information view.
 *
 * See http://www.codelearn.org/android-tutorial/android-listview for more information
 */
public class BeaconListAdapter extends BaseAdapter {

    private static final String TAG = "BeaconListAdapter";

    private ArrayList<CABeacon> mBeaconList;
    private Context mContext;

    public BeaconListAdapter(Context context) {
        this.mContext = context;
        mBeaconList = new ArrayList<>();
    }


    @Override
    public int getCount() {
        return mBeaconList.size();
    }

    @Override
    public Object getItem(int position) {
        return mBeaconList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View view, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (view == null) {
            view = inflater.inflate(R.layout.beacon_list_item, parent, false);
        }

        TextView location = (TextView) view.findViewById(R.id.beacon_list_item_location);
        TextView building = (TextView) view.findViewById(R.id.beacon_list_item_building);
        TextView distance = (TextView) view.findViewById(R.id.beacon_list_item_distance);

        location.setText(mBeaconList.get(position).getLocation());
        building.setText(mBeaconList.get(position).getBuilding());
        distance.setText(String.format("%1.2f", mBeaconList.get(position).getAccuracy()));

        return view;
    }

    public void replaceWith(ArrayList<CABeacon> collection) {
        mBeaconList.clear();
        mBeaconList.addAll(collection);
        this.notifyDataSetChanged();
    }
}
