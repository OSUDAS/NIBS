package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.ListFragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

import java.util.ArrayList;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.interfaces.IDestinationListItemSelected;

/**
 * Created by Alec on 5/3/2015.
 */
public class NavigationListFragment extends ListFragment {

    private static final String TAG = "NavigationListFragment";

    private IDestinationListItemSelected mNavigationFragment;
    private DestinationListAdapter mAdapter;

    public NavigationListFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mAdapter = new DestinationListAdapter(getActivity().getApplicationContext());
        setListAdapter(mAdapter);

        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        mNavigationFragment.openDetailView((CABeacon.Destination) mAdapter.getItem(position));
    }

    @Override
    public ListAdapter getListAdapter() {
        return this.mAdapter;
    }

    public void refreshBeaconsList(ArrayList<CABeacon.Destination> list) {
        if (getListAdapter() != null && list != null) {
            ((DestinationListAdapter) getListAdapter()).replaceWith(list);
            ((DestinationListAdapter) getListAdapter()).notifyDataSetChanged();
        }
    }

    public void setParentFragment(IDestinationListItemSelected iDestinationListItemSelected) {
        this.mNavigationFragment = iDestinationListItemSelected;
    }
}
