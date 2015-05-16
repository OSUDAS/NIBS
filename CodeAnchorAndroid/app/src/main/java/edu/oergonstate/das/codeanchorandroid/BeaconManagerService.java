package edu.oergonstate.das.codeanchorandroid;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.os.*;
import android.os.Process;
import android.preference.PreferenceManager;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.widget.Toast;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.Region;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

public class BeaconManagerService extends Service {
    private static final String TAG = "BeaconManagerService";
    private static final boolean DEBUG_LOCAL = true;

    /*  Interface for clients that bind */
    IBinder mBinder = new BeaconManagerBinder();
    /*  Indicates how to behave if the service is killed    */
    int mStartMode;
    /*  Indicates whether onRebind should be used   */
    boolean mAllowRebind;

    private Context mContext;

    private ArrayList<CABeacon> mFoundBeacons;

    /*  Beacon Manager Stuff    */
    private BeaconManager mBeaconManager;
    private static final Region ALL_ESTIMOTE_BEACONS_REGION = new Region("regionId", null, null, null);

    /*  Notifications   */
    private Intent mResultIntent;
    private PendingIntent mPendingIntent;
    private NotificationCompat.Builder mBuilder;
    private NotificationManager mNotificationManager;

    @Override
    public void onCreate() {
        mFoundBeacons = new ArrayList<>();

        HandlerThread thread = new HandlerThread("ServiceStartArguments", Process.THREAD_PRIORITY_BACKGROUND);
        thread.start();

        mServiceLooper = thread.getLooper();
        mServiceHandler = new ServiceHandler(mServiceLooper);

        mContext = getApplicationContext();

        mResultIntent = new Intent(mContext, CodeAnchorActivity.class);
        mPendingIntent = PendingIntent.getActivity(mContext, 0, mResultIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        mBuilder = new NotificationCompat.Builder(mContext)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("NIBS")
                .setContentText("")
                .setContentIntent(mPendingIntent);

        mNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        mBeaconManager = new BeaconManager(mContext);
        mBeaconManager.setRangingListener(mBeaconRangingListener);

        if (!mBeaconManager.hasBluetooth()) {
            Toast.makeText(mContext, "Device does not support Bluetooth Low Energy", Toast.LENGTH_LONG).show();
            return;
        }
        if (!mBeaconManager.isBluetoothEnabled()) {
            //TODO: Tell activity to ask to enable bluetooth
        }
        Log.i(TAG, "beacon manager connect");
        mBeaconManager.connect(mServiceReadyCallback);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Message msg = mServiceHandler.obtainMessage();
        msg.arg1 = startId;
        mServiceHandler.sendMessage(msg);

        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return mAllowRebind;
    }

    @Override
    public void onRebind(Intent intent) {
        super.onRebind(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        try {
            mBeaconManager.stopRanging(ALL_ESTIMOTE_BEACONS_REGION);
        } catch (RemoteException e) {
            Log.e(TAG, "Doesn't really matter at this point");
        }
    }

    public ArrayList<CABeacon> getFoundBeacons() {
        return mFoundBeacons;
    }


    private Looper mServiceLooper;
    private ServiceHandler mServiceHandler;

    private final class ServiceHandler extends Handler {
        public ServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            //TODO: do work here send beacon list back to activity
        }
    }

    public class BeaconManagerBinder extends Binder {
        BeaconManagerService getService() {
            return BeaconManagerService.this;
        }
    }

    private BeaconManager.RangingListener mBeaconRangingListener = new BeaconManager.RangingListener() {
        @Override
        public void onBeaconsDiscovered(Region region, List<Beacon> list) {
            Log.i(TAG, "Beacons Discovered");
            Log.i(TAG, list.toString());

            //TODO: Fetch beacon info from network and cache

            mFoundBeacons.clear();

            for (Beacon beacon : list) {
                CABeacon caBeacon = beaconIsCached(beacon);
                if (caBeacon == null) {
                    //TODO: Fetch from network
                    try {
                        JSONObject json;

                        //TODO: Temporarily fetch data from local json file
                        if (DEBUG_LOCAL) {
                            String test = "beacon" + beacon.getMajor() + beacon.getMinor() + "";
                            InputStream inputStream;

                            try {
                                inputStream = mContext.getResources().openRawResource(mContext.getResources().getIdentifier(test, "raw", mContext.getPackageName()));
                            }
                            catch (Exception e) {
                                continue;
                            }


                            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                            StringBuilder res = new StringBuilder();
                            String line;

                            while ((line = reader.readLine()) != null) {
                                res.append(line);
                                res.append('\n');
                            }

                            json = new JSONObject(res.toString());
                        }
                        else {
                            json = new FetchBeaconFromNetwork().execute(beacon.getMajor(), beacon.getMinor()).get();
                        }

                        if (json == null) return;

                        /*  Caches Results  */
                        FileOutputStream stream = openFileOutput(String.format("%d%d", beacon.getMajor(), beacon.getMinor()), MODE_PRIVATE);
                        stream.write(json.toString().getBytes());
                        stream.close();

                        Log.i("TAG", json.toString());

                        mFoundBeacons.add(CABeacon.create(beacon, json));

                    }
                    catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    catch (ExecutionException e) {
                        e.printStackTrace();
                    }
                    catch (FileNotFoundException e) {
                        e.printStackTrace();
                    }
                    catch (IOException e) {
                        e.printStackTrace();
                    }
                    catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                else {
                    mFoundBeacons.add(caBeacon);
                }

                if (PreferenceManager.getDefaultSharedPreferences(mContext).getBoolean("notification_toggle", false)) {
                    mBuilder.setContentText(caBeacon.getLocation());
                    mNotificationManager.notify(caBeacon.getMajor(), mBuilder.build());
                }
            }

        }
    };

    /**
     * Returns a CABeacon if the beacon is located in cache otherwise returns null.
     */
    private CABeacon beaconIsCached(Beacon beacon){
        final String filename = String.format("%d%d", beacon.getMajor(), beacon.getMinor());

        CABeacon b = null;

        try {
            File[] list = mContext.getFilesDir().listFiles(new FileFilter() {
                @Override
                public boolean accept(File pathname) {
                    return pathname.getName().equals(filename);
                }
            });

            if (list != null && list.length >= 1) {
                StringBuilder buffer = new StringBuilder();
                String line = "";
                BufferedReader stream = new BufferedReader(new FileReader(list[0]));
                while((line = stream.readLine()) != null) {
                    buffer.append(line);
                }
                JSONObject json = new JSONObject(buffer.toString());
                b = CABeacon.create(beacon, json);
            }
        }
        catch (FileNotFoundException e) {
            return null;
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        catch (JSONException e) {
            e.printStackTrace();
        }
        finally {
            return b;
        }
    }

    private class FetchBeaconFromNetwork extends AsyncTask<Integer, Void, JSONObject> {

        @Override
        protected JSONObject doInBackground(Integer... params) {
            if (params.length < 2) return null;

            int major = params[0];
            int minor = params[1];

            String mResult = "";

            String url = String.format("http://1-dot-capstone-bluetooth.appspot.com/capstone?majorId=%d&minorId=%d", major, minor);

            HttpResponse mHttpResponse;
            HttpClient mHttpClient = new DefaultHttpClient();
            HttpGet mHttpGet = new HttpGet(url);

            try {
                Log.i(TAG, "Querying " + url);

                mHttpResponse = mHttpClient.execute(mHttpGet);

                InputStream mInputStream = mHttpResponse.getEntity().getContent();
                BufferedReader mReader = new BufferedReader(new InputStreamReader(mInputStream, "iso-8859-1"), 8);
                StringBuilder mBuilder = new StringBuilder();
                String mLine;
                while ((mLine = mReader.readLine()) != null) {
                    mBuilder.append(mLine);
                    mBuilder.append("\n");
                }

                mReader.close();

                mResult = mBuilder.toString();

                Log.i(TAG, "Query returned " + mResult);
                return new JSONObject(mResult);
            }
            catch (IOException e) {
                e.printStackTrace();
            } catch (JSONException e) {
                e.printStackTrace();
            }
            finally {
                return null;
            }
        }
    }

    private BeaconManager.ServiceReadyCallback mServiceReadyCallback = new BeaconManager.ServiceReadyCallback() {
        @Override
        public void onServiceReady() {
            Log.i(TAG, "onServiceReady()");
            try {
                mBeaconManager.startRanging(ALL_ESTIMOTE_BEACONS_REGION);
                Log.i(TAG, "Ranging started");
            }
            catch (RemoteException e) {
                Toast.makeText(mContext, "Unable to start bluetooth ranging", Toast.LENGTH_LONG).show();
                Log.e(TAG, "Unable to start the bluetooth ranging. Something bad happened.");
            }
        }
    };
}
