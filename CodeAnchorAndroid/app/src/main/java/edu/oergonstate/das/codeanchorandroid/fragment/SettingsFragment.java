package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.preference.PreferenceFragment;

import edu.oergonstate.das.codeanchorandroid.R;

/**
 * Created by Alec on 4/20/2015.
 */
public class SettingsFragment extends PreferenceFragment {

    public SettingsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.fragment_settings);
    }
}
