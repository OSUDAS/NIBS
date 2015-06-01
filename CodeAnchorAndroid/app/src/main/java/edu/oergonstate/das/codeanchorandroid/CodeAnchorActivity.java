package edu.oergonstate.das.codeanchorandroid;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.bluetooth.BluetoothAdapter;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v13.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;

import java.util.ArrayList;

import edu.oergonstate.das.codeanchorandroid.beacon.BeaconManagerService;
import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.fragment.InformationFragment;
import edu.oergonstate.das.codeanchorandroid.fragment.NavigationFragment;
import edu.oergonstate.das.codeanchorandroid.fragment.SettingsFragment;
import edu.oergonstate.das.codeanchorandroid.interfaces.ICurrentBeacon;
import edu.oergonstate.das.codeanchorandroid.interfaces.IRefreshBeaconList;
import edu.oergonstate.das.codeanchorandroid.tab.SlidingTabLayout;

/**
 * The activity that handles the ui. It passes responsibility to its children fragments, Navigation
 * Information and Settings. This activity uses a viewpager as its ui element
 *
 * See http://developer.android.com/training/animation/screen-slide.html for more information on
 * view pagers.
 */
public class CodeAnchorActivity extends Activity implements IRefreshBeaconList, ICurrentBeacon {

    private static final String TAG = "CodeAnchor";

    private static final int NUM_PAGES = 3;
    private static final int SETTINGS_PAGE = 0;
    private static final int INFORMATION_PAGE = 1;
    private static final int NAVIGATION_PAGE = 2;

    private static final String SETTINGS_TITLE = "Settings";
    private static final String INFORMATION_TITLE = "Information";
    private static final String NAVIGATION_TITLE = "Navigation";

    private static final int REQUEST_ENABLE_BLUETOOTH = 1234;

    private Context mContext = this;

    private CABeacon mCurrentBeacon;

    ViewPager mViewPager;
    SlidingTabLayout mSlidingTabLayout;

    SettingsFragment mSettings = new SettingsFragment();
    InformationFragment mInformation = new InformationFragment();
    NavigationFragment mNavigation = new NavigationFragment();

    BeaconManagerService mBeaconManagerService;
    boolean mBound;

    /*  Lifecycle event. Check android documentation for specifics about the lifecycle  */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_code_anchor); // The layout file associated with this activity

        mViewPager = (ViewPager) findViewById(R.id.pager); //Viewpager is what gives us the swiping
        mViewPager.setAdapter(new CodeAnchorPagerAdapter(getFragmentManager()));
        mViewPager.setOffscreenPageLimit(3); //keeps all the pages loaded in memory for quicker performance

        /*  The tabs    */
        mSlidingTabLayout = (SlidingTabLayout) findViewById(R.id.sliding_tabs);
        mSlidingTabLayout.setDistributeEvenly(true);
        mSlidingTabLayout.setViewPager(mViewPager);

        /*  Start on the Information page rather than settings  */
        mViewPager.setCurrentItem(INFORMATION_PAGE, false);
    }

    @Override
    protected void onStart() {
        super.onStart();

        /* Determines if bluetooth is enabled and if not asks the users to enable it    */
        if (!BluetoothAdapter.getDefaultAdapter().isEnabled()) {
            Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(intent, REQUEST_ENABLE_BLUETOOTH);
        }

        Intent intent = new Intent(this, BeaconManagerService.class);
        bindService(intent, mServiceConnection, BIND_AUTO_CREATE);
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (mBound) {
            unbindService(mServiceConnection);
            mBound = false;
        }
    }

    /*  Handle the back button not handled natively with our implementation.    */
    @Override
    public void onBackPressed() {
        int currentPage = mViewPager.getCurrentItem();
        switch (currentPage) {
            case INFORMATION_PAGE:
                mInformation.returnToList();
                break;
            case NAVIGATION_PAGE:
                mNavigation.returnToList();
                break;
            default:
                super.onBackPressed();
        }
    }

    /*  Callback for children to access detected beacons    */
    @Override
    public ArrayList<CABeacon> refreshBeaconList() {
        return mBeaconManagerService.getFoundBeacons();
    }

    /*  Callback to set which beacon is currently selected  */
    @Override
    public void setCurrentBeacon(CABeacon beacon) {
        this.mCurrentBeacon = beacon;
    }

    /*  Callback to detect which beacon is currently selected   */
    @Override
    public CABeacon getCurrentBeacon() {
        return this.mCurrentBeacon;
    }

    private class CodeAnchorPagerAdapter extends FragmentStatePagerAdapter {

        public CodeAnchorPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                case SETTINGS_PAGE:
                    return SETTINGS_TITLE;
                case INFORMATION_PAGE:
                    return INFORMATION_TITLE;
                case NAVIGATION_PAGE:
                    return NAVIGATION_TITLE;
                default:
                    return "";
            }
        }

        @Override
        public Fragment getItem(int i) {
            switch (i) {
                case SETTINGS_PAGE:
                    return mSettings;
                case INFORMATION_PAGE:
                    return mInformation;
                case NAVIGATION_PAGE:
                    return mNavigation;
                default:
                    return mSettings;
            }
        }

        @Override
        public int getCount() {
            return NUM_PAGES;
        }
    }

    private ServiceConnection mServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            Log.i(TAG, "Service is connected");
            BeaconManagerService.BeaconManagerBinder binder = (BeaconManagerService.BeaconManagerBinder) service;
            mBeaconManagerService = binder.getService();
            mBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mBound = false;
        }
    };
}
