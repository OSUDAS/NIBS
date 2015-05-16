package edu.oergonstate.das.codeanchorandroid;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Alec on 4/20/2015.
 */
public class NavigationFragment extends Fragment implements IDestinationListItemSelected, IReturnToList {

    private static final int TIMER_PERIOD = 1000;
    private static final int TIMER_DELAY = 0;

    private NavigationListFragment listFragment;
    private IRefreshBeaconList mActivity;
    private ICurrentBeacon mCurrentBeacon;

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
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(false);
        getFragmentManager().beginTransaction().replace(R.id.navigation_content, listFragment).commit();
    }
    @Override
    public void openDetailView(CABeacon.Destination destination) {
        NavigationDetailFragment fragment = NavigationDetailFragment.newInstance(destination);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);

        getFragmentManager().beginTransaction().replace(R.id.navigation_content, fragment).commit();
    }
}
