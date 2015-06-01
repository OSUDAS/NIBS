package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import java.util.Timer;
import java.util.TimerTask;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.R;
import edu.oergonstate.das.codeanchorandroid.interfaces.IBeaconListItemSelected;
import edu.oergonstate.das.codeanchorandroid.interfaces.ICurrentBeacon;
import edu.oergonstate.das.codeanchorandroid.interfaces.IRefreshBeaconList;
import edu.oergonstate.das.codeanchorandroid.interfaces.IReturnToList;

public class InformationFragment extends Fragment implements IBeaconListItemSelected, IReturnToList {

    private static final int TIMER_PERIOD = 1000;
    private static final int TIMER_DELAY = 0;

    private InformationListFragment listFragment;
    private IRefreshBeaconList mActivity;
    private ICurrentBeacon mCurrentBeacon;

    private boolean isList;

    public InformationFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_information, container, false);
        mActivity = (IRefreshBeaconList) getActivity();
        mCurrentBeacon = (ICurrentBeacon) getActivity();

        listFragment = new InformationListFragment();
        listFragment.setParentFragment(this);
        getFragmentManager().beginTransaction().replace(R.id.information_content, listFragment).commit();
        isList = true;

        /*  Every second refresh the list of beacons */
        new Timer().scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        listFragment.refreshBeaconsList(mActivity.refreshBeaconList());
                    }
                });
            }
        }, TIMER_DELAY, TIMER_PERIOD);

        return view;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Log.i("TAG", "test");
        switch (item.getItemId()) {
            case android.R.id.home:
                returnToList();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    /*  Opens the details of the tapped list item   */
    @Override
    public void openDetailView(CABeacon beacon) {

        InformationDetailFragment fragment = InformationDetailFragment.newInstance(beacon);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true); //FIXME check for null

        mCurrentBeacon.setCurrentBeacon(beacon);

        isList = false;

        getFragmentManager().beginTransaction().replace(R.id.information_content, fragment).commit();
    }

    /*  Returns to list from detail fragments   */
    @Override
    public void returnToList() {
        if (!isList) {
            getActivity().getActionBar().setDisplayHomeAsUpEnabled(false); //FIXME check for null
            getFragmentManager().beginTransaction().replace(R.id.information_content, listFragment).commit();
            isList = true;

        }
    }
}
