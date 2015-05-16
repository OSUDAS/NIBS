package edu.oergonstate.das.codeanchorandroid;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.Utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class CABeacon implements Parcelable {

    public static final String BUILDING_KEY = "building";
    public static final String LOCATION_KEY = "location";
    public static final String INFORMATION_KEY = "info";
    public static final String SUBJECT_KEY = "subject";
    public static final String NAVIGATION_KEY = "navigation";

    public static final String STEPS_KEY = "steps";
    public static final String STEPS_NUM_KEY = "stepNum";
    public static final String INSTRUCTION_KEY = "instruction";
    public static final String MAJOR_ID_KEY = "majorID";

    private static String TAG = "CABeacon";

    private Beacon mBeacon;
    private double mAccuracy;

    private Navigation mNavigation;

    private String mBuilding;
    private String mLocation;
    private String mInformation;
    private String mSubject;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeDouble(mAccuracy);
        mBeacon.writeToParcel(dest, flags);
    }

    public static final Parcelable.Creator<CABeacon> CREATOR = new Parcelable.Creator<CABeacon>() {
        public CABeacon createFromParcel(Parcel in) {
            return new CABeacon(in);
        }

        public CABeacon[] newArray(int size) {
            return new CABeacon[size];
        }
    };

    private CABeacon(Parcel in) {
        mAccuracy = in.readInt();
        mBeacon = Beacon.CREATOR.createFromParcel(in);
    }

    private CABeacon(Beacon beacon, JSONObject json) {
        this.mBeacon = beacon;

        if (this.mBeacon != null) {
            this.mAccuracy = Utils.computeAccuracy(beacon);
        }

        setJsonFields(json);
    }


    public static CABeacon create(Beacon beacon, JSONObject json) {
        return new CABeacon(beacon, json);
    }

    public CABeacon(JSONObject json) {
        setJsonFields(json);
    }

    private void setJsonFields(JSONObject json) {
        try {
            this.mBuilding = json.getString(BUILDING_KEY);
            this.mLocation = json.getString(LOCATION_KEY);
            this.mInformation = json.getString(INFORMATION_KEY);
            this.mSubject = json.getString(SUBJECT_KEY);

            JSONObject object = json.getJSONArray(NAVIGATION_KEY).getJSONObject(0);

            this.mNavigation = new Navigation();
            this.mNavigation.destination = new Destination(object.getInt("majorID"), object.getInt("minorID"),
                    "", object.getString("subject"), object.getString("distance"), object.getString("info"));
            JSONArray array = object.getJSONArray(STEPS_KEY);

            this.mNavigation.steps = new ArrayList<>();

            for (int i = 0; i < array.length(); i++) {
                JSONObject obj = array.getJSONObject(i);
                mNavigation.steps.add(new Step(obj.getInt(STEPS_NUM_KEY), obj.getString(INSTRUCTION_KEY), obj.getInt(MAJOR_ID_KEY)));
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static CABeacon createFromJson(JSONObject jsonObject) {
        return new CABeacon(jsonObject);
    }

    public String getSubject() {
        return mSubject;
    }

    public void setSubject(String mSubject) {
        this.mSubject = mSubject;
    }

    public String getInformation() {
        return mInformation;
    }

    public void setInformation(String mInformation) {
        this.mInformation = mInformation;
    }

    public String getLocation() {
        return mLocation;
    }

    public void setLocation(String mLocation) {
        this.mLocation = mLocation;
    }

    public String getBuilding() {
        return mBuilding;
    }

    public void setBuilding(String mBuilding) {
        this.mBuilding = mBuilding;
    }

    public double getAccuracy() {
        if (mBeacon != null) {
            return this.mAccuracy;
        }
        return this.mAccuracy;
    }

    public Navigation getNavigation() {
        return this.mNavigation;
    }

    public int getMajor() {
        return this.mBeacon.getMajor();
    }

    public int getMinor() {
        return this.mBeacon.getMinor();
    }

    public ArrayList<Destination> getDestinations() {
        ArrayList<Destination> beacons = new ArrayList<>();

        if (mNavigation == null || mNavigation.destination == null) return null;
        beacons.add(mNavigation.destination);
        return beacons;
    }

    public class Navigation {
        Destination destination;
        ArrayList<Step> steps;
    }

    public class Step {
        int stepNum;
        String instruction;
        int majorId;

        public Step(int stepNum, String instruction, int majorId) {
            this.stepNum = stepNum;
            this.instruction = instruction;
            this.majorId = majorId;
        }
    }

    public class Destination {
        int majorID;
        int minorID;
        String location;
        String subject;
        String distance;
        String info;

        public Destination(int majorID, int minorID, String location, String subject, String distance, String info) {
            this.majorID = majorID;
            this.minorID = minorID;
            this.distance = distance;
            this.info = info;
            this.subject = subject;
            this.location = location;
        }
    }
}
