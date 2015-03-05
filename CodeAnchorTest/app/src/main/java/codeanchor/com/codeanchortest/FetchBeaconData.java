package codeanchor.com.codeanchortest;

import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * Given a major and minor id of the beacon will query the server for the json data about that beacon.
 */
public class FetchBeaconData extends AsyncTask<Integer, Void, String> {
    private static final String TAG = "FetchBeaconData";

    @Override
    protected String doInBackground(Integer... params) {
        int major = params[1];
        int minor = params[2];

        String mResult = "";

        String url = String.format("http://1-dot-capstone-bluetooth.appspot.com/capstone?majorID=%d&minorId=%d", major, minor);

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
        }
        catch (IOException e) {
            e.printStackTrace();
        }

        Log.i(TAG, "Query returned " + mResult);
        return mResult;
    }
}
