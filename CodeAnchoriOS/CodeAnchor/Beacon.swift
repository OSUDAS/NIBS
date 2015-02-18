//
//  Beacon.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/3/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import Foundation

class Beacon: BeaconInfo{
    
    var distance:Int = 0
    
    var information:NSArray = [InfoBucket]()
    var navigation:NSArray = [NavDirectory]()
    
    override var description: String{
        return "{majorID: \(majorID), minorID: \(minorID), building: \(building), location: \(location), distance: \(distance),\n\tinformation: \(information),\n\tnavigation: \(navigation)}"
    }
    
}
