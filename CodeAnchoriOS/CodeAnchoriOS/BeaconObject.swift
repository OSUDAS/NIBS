//
//  Beacon.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/22/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation

class BeaconObject: NSObject {

    var majorID: NSNumber?
    var minorID: NSNumber?
    var building: String?
    var subject: String?
    var info: String?
    var distance: NSNumber?
    var location: String?
    var navigationDirectories: [NavigationDirectoryObject]?
    
    init(beacon: Beacon, includeNav: Bool){
        majorID = beacon.majorID
        minorID = beacon.minorID
        building = beacon.building
        subject = beacon.subject
        info = beacon.info
        distance = beacon.distance
        location = beacon.location
        if(includeNav){
            var navDirectories = [NavigationDirectoryObject]()
            for ND in beacon.navigationDirectories{
                var directory = ND as NavigationDirectory
                navDirectories.append(NavigationDirectoryObject(navDirectory: directory))
            }
            
            navigationDirectories = navDirectories
        }
        
    }

}
