package edu.oergonstate.das.codeanchorandroid;

import android.app.Fragment;
import android.content.Context;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.media.session.MediaSession;
import android.nfc.Tag;
import android.os.Bundle;
import android.os.Handler;
import android.os.Vibrator;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.estimote.sdk.Beacon;

import java.util.ArrayList;
import java.util.FormatFlagsConversionMismatchException;
import java.util.Timer;
import java.util.TimerTask;

public class NavigationDetailFragment extends Fragment {

    private static final String TAG = "NavigationDetail";

    private static final String PARAM_BEACON = "beacon_param";
    private static final int MAX_TIMER_DELAY = 5000;
    private static final int SECOND = 1000;

    private IReturnToList mParentFragment;
    private ICurrentBeacon mCurrentBeacon;

    private int mStepNum;
    ArrayList<CABeacon> beacons;
    private int mDelay = MAX_TIMER_DELAY;
    CABeacon.Navigation navigation;

    private TextView mInfoTextView;

    private int mLocationOld = 0;
    private int mLocationNew = 0;


    CABeacon beacon1;
    CABeacon beacon2;

    private CABeacon mBeaconParam;

    public static NavigationDetailFragment newInstance(CABeacon.Destination beacon) {
        NavigationDetailFragment fragment = new NavigationDetailFragment();
//        Bundle args = new Bundle();
//        args.putParcelable(PARAM_BEACON, beacon);
//        fragment.setArguments(args);
        return fragment;
    }

    Vibrator vibrator;
    ToneGenerator generator = new ToneGenerator(AudioManager.STREAM_MUSIC, ToneGenerator.MAX_VOLUME);

    Handler handler = new Handler();
    Runnable runnable = new Runnable() {
        @Override
        public void run() {

            //TODO vibrate

            if (PreferenceManager.getDefaultSharedPreferences(getActivity().getApplicationContext()).getBoolean("buzz_toggle", false)) {
                vibrator.vibrate(500);
            }

            if (PreferenceManager.getDefaultSharedPreferences(getActivity().getApplicationContext()).getBoolean("tone_toggle", false)) {
                generator.startTone(ToneGenerator.TONE_DTMF_0, 500);
            }

            switch (mStepNum) {
                case 1:
                    mDelay = SECOND * 4;
                    break;
                case 2:
                    mDelay = SECOND * 3;
                    break;
                case 3:
                    mDelay = SECOND * 2;
                    break;
                case 4:
                    mDelay = SECOND * 1;
                    break;
                default:
                    mDelay = SECOND;
            }

            Log.i("TESTING", "" + mStepNum);

            handler.postDelayed(runnable, mDelay);
        }
    };

    public NavigationDetailFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        Bundle bundle = getArguments();
//        this.mBeaconParam = bundle.getParcelable(PARAM_BEACON);

        this.mCurrentBeacon = (ICurrentBeacon) getActivity();
        navigation = mCurrentBeacon.getCurrentBeacon().getNavigation();

        vibrator = (Vibrator) getActivity().getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        runnable.run();

        new Timer().scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                beacons = ((IRefreshBeaconList) getActivity()).refreshBeaconList();
                if (beacons == null || beacons.isEmpty()) return;
                beacon1 = beacons.get(0);

//                Log.i(TAG, beacon1.getMajor() + "");

                for (final CABeacon.Step step : navigation.steps) {
                    if (step.majorId == beacon1.getMajor()) {


                        mLocationNew = step.stepNum;

                        Log.i(TAG, mLocationNew + " " + mLocationOld);

                        if (mLocationNew > mLocationOld) {
                            mStepNum = step.stepNum;

                            getActivity().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    mInfoTextView.setText(step.instruction);
                                }
                            });
                        }

                        mLocationOld = mLocationNew;
                    }
                }
            }
        }, 0, 1000);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        //TODO: figure out ui
        View view = inflater.inflate(R.layout.fragment_navigation_detail, container, false);


        this.mInfoTextView = (TextView) view.findViewById(R.id.navigation_detail_instruction);


        return view;
    }


}
