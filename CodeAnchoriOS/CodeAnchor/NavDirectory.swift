//
//  NavDirectory.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import Foundation


class NavDirectory:BeaconInfo {
    var steps = [String]()
    
    override var description: String {
        return "NavDir{majorID: \(majorID), minorID: \(minorID), location: \(location), \n\tsteps: \(steps)}"
    }
}