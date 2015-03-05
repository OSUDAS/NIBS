package codeanchor.com.codeanchortest;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.Region;
import com.estimote.sdk.Utils;
import com.estimote.sdk.utils.L;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;

public class MyActivity extends Activity {
    
    private static final String TAG = MyActivity.class.getSimpleName();

    private static final Region ALL_ESTIMOTE_BEACONS_REGION = new Region("regionId", null, null, null);

    private static final int REQUEST_ENABLE_BLUETOOTH = 1234;

    TextView major, minor, distance;

    private BeaconManager beaconManager;
//    private BeaconListAdapter adapter;

    Button requestButton;
    TextView responseText;

    private Beacon currentBeacon = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (getActionBar() != null) getActionBar().setDisplayHomeAsUpEnabled(true);

        major = (TextView) findViewById(R.id.Major);
        minor = (TextView) findViewById(R.id.Minor);
        distance = (TextView) findViewById(R.id.Distance);

        responseText = (TextView) findViewById(R.id.response);

//        requestButton = (Button) findViewById(R.id.requestButton);
//        requestButton.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                NetworkCode c = new NetworkCode();
//                try {
//                    String string = c.execute().get();
//                    responseText.setText(string);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                } catch (ExecutionException e) {
//                    e.printStackTrace();
//                }
//            }
//        });

        /*  Configure device list   */


        /*  Configure verbose debug logging */
        L.enableDebugLogging(false);

        /*  Configure BeaconManager */
        beaconManager = new BeaconManager(this);
        beaconManager.setRangingListener(new BeaconManager.RangingListener() {
            @Override
            public void onBeaconsDiscovered(Region region, final List<Beacon> beacons) {
//                Log.e(TAG, "Beacon Discovered");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (beacons.size() < 1) return;
                        if (currentBeacon != null && currentBeacon.equals(beacons.get(0))) return;
                        currentBeacon = beacons.get(0);
                        getActionBar().setSubtitle("Found Beacons: " + beacons.size());
                        Log.i(TAG, beacons.toString());
                        major.setText(Integer.toString(beacons.get(0).getMajor()));
                        minor.setText(Integer.toString(beacons.get(0).getMinor()));
                        distance.setText(String.format("%.2fm", Utils.computeAccuracy(beacons.get(0))));
                    }
                });
            }
        });
    }

    class NetworkCode extends AsyncTask<Void, Void, String> {

        InputStream stream;

        @Override
        protected String doInBackground(Void... params) {
            String str = "";

            String url9583 = "http://1-dot-capstone-bluetooth.appspot.com/capstone?majorId=9583&minorId=8338";
            String url3867 = "http://1-dot-capstone-bluetooth.appspot.com/capstone?majorId=3867";

            HttpResponse response;
            HttpClient myClient = new DefaultHttpClient();
            HttpGet myConnection = new HttpGet(url9583);

            try {
                Log.i(TAG, "Querying " + url9583);

                response = myClient.execute(myConnection);

                stream = response.getEntity().getContent();
                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(stream, "iso-8859-1"), 8);
                StringBuilder builder = new StringBuilder();
                String line = null;
                while ((line = bufferedReader.readLine()) != null) {
                    builder.append(line);
                    builder.append("\n");
                }

                stream.close();

                str = builder.toString();
            }
            catch (ClientProtocolException e) {
                e.printStackTrace();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
            Log.i(TAG, str);
            return str;
        }
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
