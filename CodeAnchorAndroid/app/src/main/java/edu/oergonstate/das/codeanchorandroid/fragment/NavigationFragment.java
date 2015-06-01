package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import java.util.Timer;
import java.util.TimerTask;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.R;
import edu.oergonstate.das.codeanchorandroid.interfaces.ICurrentBeacon;
import edu.oergonstate.das.codeanchorandroid.interfaces.IDestinationListItemSelected;
import edu.oergonstate.das.codeanchorandroid.interfaces.IRefreshBeaconList;
import edu.oergonstate.das.codeanchorandroid.interfaces.IReturnToList;

/**
 * Created by Alec on 4/20/2015.
 */
public class NavigationFragment extends Fragment implements IDestinationListItemSelected, IReturnToList {

    private static final int TIMER_PERIOD = 1000;
    private static final int TIMER_DELAY = 0;

    private NavigationListFragment listFragment;
    private IRefreshBeaconList mActivity;
    private ICurrentBeacon mCurrentBeacon;

    private boolean isList;

    public NavigationFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_navigation, container, false);

        mActivity = (IRefreshBeaconList) getActivity();
        mCurrentBeacon = (ICurrentBeacon) getActivity();

        listFragment = new NavigationListFragment();
        listFragment.setParentFragment(this);

        getFragmentManager().beginTransaction().replace(R.id.navigation_content, listFragment).commit();
        isList = true;

        new Timer().scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mCurrentBeacon.getCurrentBeacon() != null) {
                            listFragment.refreshBeaconsList(mCurrentBeacon.getCurrentBeacon().getDestinations());
                        }
                    }
                });
            }
        }, TIMER_DELAY, TIMER_PERIOD);

        return view;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                returnToList();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void returnToList() {
        if(!isList) {
            getActivity().getActionBar().setDisplayHomeAsUpEnabled(false);
            getFragmentManager().beginTransaction().replace(R.id.navigation_content, listFragment).commit();
            isList = true;
        }
    }
    @Override
    public void openDetailView(CABeacon.Destination destination) {
        NavigationDetailFragment fragment = NavigationDetailFragment.newInstance(destination);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);

        isList = false;

        getFragmentManager().beginTransaction().replace(R.id.navigation_content, fragment).commit();
    }
}
