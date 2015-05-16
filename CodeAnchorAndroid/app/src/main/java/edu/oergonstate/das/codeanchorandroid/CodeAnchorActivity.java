package edu.oergonstate.das.codeanchorandroid;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.support.v13.app.FragmentStatePagerAdapter;
import android.util.Log;

import java.util.ArrayList;

/**
 * Created by Alec on 4/17/2015.
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
//    PagerTabStrip mPagerTabStrip;

    SettingsFragment mSettings = new SettingsFragment();
    InformationFragment mInformation = new InformationFragment();
    NavigationFragment mNavigation = new NavigationFragment();

    BeaconManagerService mBeaconManagerService;
    boolean mBound;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_code_anchor);

        mViewPager = (ViewPager) findViewById(R.id.pager);
        mViewPager.setAdapter(new CodeAnchorPagerAdapter(getFragmentManager()));
        mViewPager.setOffscreenPageLimit(3);

        mSlidingTabLayout = (SlidingTabLayout) findViewById(R.id.sliding_tabs);
        mSlidingTabLayout.setDistributeEvenly(true);
        mSlidingTabLayout.setViewPager(mViewPager);

//        mPagerTabStrip = (PagerTabStrip) findViewById(R.id.pager_title_strip);

        mViewPager.setCurrentItem(INFORMATION_PAGE, false);
    }

    @Override
    protected void onStart() {
        super.onStart();

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

    @Override
    public ArrayList<CABeacon> refreshBeaconList() {
        return mBeaconManagerService.getFoundBeacons();
    }

    @Override
    public void setCurrentBeacon(CABeacon beacon) {
        this.mCurrentBeacon = beacon;
    }

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
