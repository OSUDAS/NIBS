package codeanchor.com.codeanchortest;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Toast;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.Region;
import com.estimote.sdk.Utils;
import com.estimote.sdk.utils.L;

import java.util.List;

public class MyActivity extends Activity {
    
    private static final String TAG = MyActivity.class.getSimpleName();

    private static final Region ALL_ESTIMOTE_BEACONS_REGION = new Region("regionId", null, null, null);

    private static final int REQUEST_ENABLE_BLUETOOTH = 1234;

    TextView major, minor, distance;

    private BeaconManager beaconManager;
//    private BeaconListAdapter adapter;

    private Beacon currentBeacon = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my);
        if (getActionBar() != null) getActionBar().setDisplayHomeAsUpEnabled(true);

        major = (TextView) findViewById(R.id.Major);
        minor = (TextView) findViewById(R.id.Minor);
        distance = (TextView) findViewById(R.id.Distance);

        /*  Configure device list   */


        /*  Configure verbose debug logging */
        L.enableDebugLogging(false);

        /*  Configure BeaconManager */
        beaconManager = new BeaconManager(this);
        beaconManager.setRangingListener(new BeaconManager.RangingListener() {
            @Override
            public void onBeaconsDiscovered(Region region, final List<Beacon> beacons) {
                Log.e(TAG, "Beacon Discovered");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (beacons.size() < 1) return;
                        if (currentBeacon != null && currentBeacon.equals(beacons.get(0))) return;
                        currentBeacon = beacons.get(0);
                        getActionBar().setSubtitle("Found Beacons: " + beacons.size());
                        Log.e(TAG, beacons.get(0).toString());
                        major.setText(Integer.toString(beacons.get(0).getMajor()));
                        minor.setText(Integer.toString(beacons.get(0).getMinor()));
                        distance.setText(String.format("%.2fm", Utils.computeAccuracy(beacons.get(0))));
                    }
                });
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (!beaconManager.hasBluetooth()) {
            Toast.makeText(this, "Device does not support Bluetooth Low Energy", Toast.LENGTH_LONG).show();
            return;
        }

        if (!beaconManager.isBluetoothEnabled()) {
            Intent enableBluetoothIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBluetoothIntent, REQUEST_ENABLE_BLUETOOTH);
        }
        else {
            connectToService();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        try {
            beaconManager.stopRanging(ALL_ESTIMOTE_BEACONS_REGION);
        } catch (RemoteException e) {
            Log.e(TAG, "Cannot stop but it does not matter now", e);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        beaconManager.disconnect();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.my, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void connectToService() {
        if (getActionBar() != null) getActionBar().setSubtitle("Scanning...");
        beaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                try {
                    beaconManager.startRanging(ALL_ESTIMOTE_BEACONS_REGION);
                } catch (RemoteException e) {
                    Toast.makeText(MyActivity.this, "Cannot start ranging, something terrible happened", Toast.LENGTH_LONG).show();
                    Log.e(TAG, "Cannot start ranging");
                }
            }
        });
    }
}
