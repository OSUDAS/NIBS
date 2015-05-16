package edu.oergonstate.das.codeanchorandroid;

import android.app.Fragment;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import java.util.Timer;
import java.util.TimerTask;

public class InformationFragment extends Fragment implements IBeaconListItemSelected, IReturnToList {

    private static final int TIMER_PERIOD = 1000;
    private static final int TIMER_DELAY = 0;

    private InformationListFragment listFragment;
    private IRefreshBeaconList mActivity;
    private ICurrentBeacon mCurrentBeacon;

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

    @Override
    public void openDetailView(CABeacon beacon) {

        InformationDetailFragment fragment = InformationDetailFragment.newInstance(beacon);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);

        mCurrentBeacon.setCurrentBeacon(beacon);


        getFragmentManager().beginTransaction().replace(R.id.information_content, fragment).commit();
    }

    @Override
    public void returnToList() {
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(false);
        getFragmentManager().beginTransaction().replace(R.id.information_content, listFragment).commit();
    }
}
