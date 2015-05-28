package edu.oergonstate.das.codeanchorandroid.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;
import edu.oergonstate.das.codeanchorandroid.R;
import edu.oergonstate.das.codeanchorandroid.interfaces.IReturnToList;

/**
 * Shows the details of the selected beacon;
 *
 * @author Alec Rietman
 */
public class InformationDetailFragment extends Fragment {

    private static final String PARAM_BEACON = "beacon_param";

    private IReturnToList mParentFragment;

    private CABeacon mBeaconParam;

    public static InformationDetailFragment newInstance(CABeacon beacon) {
        InformationDetailFragment fragment = new InformationDetailFragment();
        Bundle args = new Bundle();
        args.putParcelable(PARAM_BEACON, beacon);
        fragment.setArguments(args);
        return fragment;
    }


    public InformationDetailFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        Bundle bundle = this.getArguments();
        this.mBeaconParam = bundle.getParcelable(PARAM_BEACON);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_beacon_detail, container, false);

        TextView beaconLocation = (TextView) view.findViewById(R.id.detail_beacon_location);
        TextView beaconInfo = (TextView) view.findViewById(R.id.detail_beacon_info);
        TextView beaconBuilding = (TextView) view.findViewById(R.id.detail_beacon_building);

        beaconLocation.setText(this.mBeaconParam.getLocation());
        beaconInfo.setText(this.mBeaconParam.getInformation());
        beaconBuilding.setText(this.mBeaconParam.getBuilding());

        return view;
    }

}
