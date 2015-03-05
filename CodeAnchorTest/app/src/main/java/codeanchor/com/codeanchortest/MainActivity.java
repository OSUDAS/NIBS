package codeanchor.com.codeanchortest;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.app.Fragment;
import android.os.RemoteException;
import android.preference.PreferenceManager;
import android.support.v13.app.FragmentStatePagerAdapter;
import android.support.v4.app.NotificationCompat;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.Region;

import java.lang.annotation.ElementType;
import java.util.List;
import java.util.concurrent.ExecutionException;


public class MainActivity extends Activity {

    private static final String TAG = "CodeAnchor";

    private static final int NUM_PAGES = 3;
    private static final int REQUEST_ENABLE_BLUETOOTH = 1234;

    private Context mContext = this;

    /*  UI stuff    */
    private ViewPager mViewPager;
    private SlidingTabLayout mSlidingTabLayout;

    /*  Beacon stuff    */
    private BeaconManager mBeaconManager;
    private Beacon mCurrentBeacon = null;
    private static final Region ALL_ESTIMOTE_BEACONS_REGION = new Region("regionId", null, null, null);


    /*  Notification stuff  */
    Intent mResultIntent;
    PendingIntent mPendingIntent;
    private NotificationCompat.Builder mBuilder;
    private int mNotificationId = 13;

    NotificationManager mNotifyMgr;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mViewPager = (ViewPager) findViewById(R.id.pager);
        mViewPager.setAdapter(new CodeAnchorPagerAdapter(getFragmentManager()));

        mSlidingTabLayout = (SlidingTabLayout) findViewById(R.id.sliding_tabs);
        mSlidingTabLayout.setDistributeEvenly(true);
        mSlidingTabLayout.setViewPager(mViewPager);

        mResultIntent = new Intent(mContext, MainActivity.class);
        mPendingIntent = PendingIntent.getActivity(mContext, 0, mResultIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        mBuilder = new NotificationCompat.Builder(mContext)
                .setSmallIcon(R.drawable.ic_launcher)
                .setContentTitle("Notification Test")
                .setContentText("This is a test of notification builder")
                .setContentIntent(mPendingIntent);

        mNotifyMgr = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        // TODO handle detection of beacons.
        mBeaconManager = new BeaconManager(mContext);
        mBeaconManager.setRangingListener(mBeaconRangingListener);

    }

    @Override
    protected void onStart() {
        super.onStart();
        if (!mBeaconManager.hasBluetooth()) {
            Toast.makeText(mContext, "Device does not support BLE", Toast.LENGTH_LONG).show();
            return;
        }
        if (!mBeaconManager.isBluetoothEnabled()) {
            Intent mEnableBluetoothIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(mEnableBluetoothIntent, REQUEST_ENABLE_BLUETOOTH);
        }
        else {
            mBeaconManager.connect(mServiceReadyCallback);
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        try {
            mBeaconManager.stopRanging(ALL_ESTIMOTE_BEACONS_REGION);
        }
        catch (RemoteException e) {
            Log.e(TAG, "Cannot stop but it doesn't matter now.");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mBeaconManager.disconnect();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    private BeaconManager.ServiceReadyCallback mServiceReadyCallback = new BeaconManager.ServiceReadyCallback() {
        @Override
        public void onServiceReady() {
            try {
                mBeaconManager.startRanging(ALL_ESTIMOTE_BEACONS_REGION);
            }
            catch (RemoteException e) {
                Toast.makeText(mContext, "Unable to start bluetooth ranging", Toast.LENGTH_LONG).show();
                Log.e(TAG, "Unable to start the bluetooth rangig something bad happened");
            }
        }
    };

    private BeaconManager.RangingListener mBeaconRangingListener = new BeaconManager.RangingListener() {
        @Override
        public void onBeaconsDiscovered(Region region, List<Beacon> beacons) {
            Log.i(TAG, "Beacon Discovered");
            Log.i(TAG, beacons.toString());

            try {
                for (Beacon beacon : beacons) {
                    String mJson = (new FetchBeaconData()).execute(beacon.getMajor(), beacon.getMinor()).get();
                    Log.i(TAG, mJson);
                }
            }
            catch (InterruptedException | ExecutionException e) {
                Log.e(TAG, "Error fetching the Beacon information from the server.");
                e.printStackTrace();
            }

            // TODO Notifications.

            if (PreferenceManager.getDefaultSharedPreferences(mContext).getBoolean("notification_toggle", false)) {
                mNotifyMgr.notify(mNotificationId, mBuilder.build());
            }
        }
    };

    private class CodeAnchorPagerAdapter extends FragmentStatePagerAdapter {

        private SettingsFragment settings = new SettingsFragment();
        private InformationFragment information = new InformationFragment();
        private NavigationFragment navigation = new NavigationFragment();

        public CodeAnchorPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                case 0:
                    return "Settings";
                case 1:
                    return "Information";
                case 2:
                    return "Navigation";
            }
            return null;
        }

        @Override
        public Fragment getItem(int i) {
            switch (i) {
                case 0:
                    return settings;
                case 1:
                    return information;
                case 2:
                    return  navigation;
            }
            return null;
        }

        @Override
        public int getCount() {
            return NUM_PAGES;
        }
    }
}
