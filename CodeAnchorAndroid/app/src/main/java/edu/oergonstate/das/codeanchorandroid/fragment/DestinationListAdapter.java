package edu.oergonstate.das.codeanchorandroid.fragment;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.R;

/**
 * The list adapter handling the list of destinations.
 */
public class DestinationListAdapter extends BaseAdapter {

    private static final String TAG = "BeaconListAdapter";

    private ArrayList<CABeacon.Destination> mBeaconList;
    private Context mContext;

    public DestinationListAdapter(Context context) {
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

//        location.setText(mBeaconList.get(position).location);
//        building.setText("");
//        distance.setText("");

        return view;
    }

    public void replaceWith(ArrayList<CABeacon.Destination> collection) {
        mBeaconList.clear();
        mBeaconList.addAll(collection);
        this.notifyDataSetChanged();
    }
}
