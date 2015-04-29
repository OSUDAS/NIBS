//
//  StepObject.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation

class StepObject: NSObject {
    
    var imageURL: String?
    var instruction: String?
    var beaconID: NSNumber?
    var stepNum: NSNumber?
    
    init(step: Step){
        stepNum = step.stepNum
        imageURL = step.imageURL
        instruction = step.instruction
        beaconID = step.beaconID
    }
}