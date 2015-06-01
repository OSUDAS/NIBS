//
//  NavigationDirectoryObject.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation


class NavigationDirectoryObject: NSObject {
    
    var building: String?
    var subject: String?
    var toBeacon: NSNumber?
    var steps: [StepObject]?
    var destination: String?
    
    init(navDirectory: NavigationDirectory){
        
        toBeacon = navDirectory.toBeaconID
        subject = navDirectory.subject
        building = navDirectory.building
        destination = navDirectory.destination

        var steps = [StepObject]()
        for s in navDirectory.steps{
            var step = s as Step
            steps.append(StepObject(step: step))
        }
        
        self.steps = steps
    }
    
}
