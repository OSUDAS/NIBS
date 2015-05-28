package edu.oergonstate.das.codeanchorandroid.interfaces;

import edu.oergonstate.das.codeanchorandroid.beacon.CABeacon;

/**
 * Created by Alec on 5/3/2015.
 */
public interface ICurrentBeacon {
    void setCurrentBeacon(CABeacon beacon);
    CABeacon getCurrentBeacon();
}
