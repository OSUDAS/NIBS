//
//  Step.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation
import CoreData

@objc(Step)
class Step: NSManagedObject {

    @NSManaged var beaconID: NSNumber?
    @NSManaged var imageURL: String?
    @NSManaged var instruction: String
    @NSManaged var stepNum: NSNumber
    @NSManaged var navigationDirectory: NavigationDirectory

}
