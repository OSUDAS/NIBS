package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.Activity;
import android.app.ListFragment;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

import java.util.ArrayList;

import edu.oergonstate.das.codeanchorandroid.beacon.BeaconListAdapter;
import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.interfaces.IBeaconListItemSelected;

/**
 * Created by Alec on 4/22/2015.
 */
public class InformationListFragment extends ListFragment {

    private static final String TAG = "InformationListFragment";

    private IBeaconListItemSelected mInformationFragment;
    private BeaconListAdapter mAdapter;

    public InformationListFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        Log.i(TAG, "onCreateView");
        mAdapter = new BeaconListAdapter(getActivity().getApplicationContext());
        setListAdapter(mAdapter);

        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        mInformationFragment.openDetailView((CABeacon) mAdapter.getItem(position));

    }

    @Override
    public ListAdapter getListAdapter() {
        return mAdapter;
    }

    public void refreshBeaconsList(ArrayList<CABeacon> list) {
        if (getListAdapter() != null) {
            Log.i(TAG, "List adapter not null");
            ((BeaconListAdapter) getListAdapter()).replaceWith(list);
            ((BeaconListAdapter) getListAdapter()).notifyDataSetChanged();
        }

    }

    public void setParentFragment(IBeaconListItemSelected iBeaconListItemSelected) {
        this.mInformationFragment = iBeaconListItemSelected;
    }
}
