//
//  Beacon.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation
import CoreData

@objc(Beacon)
class Beacon: NSManagedObject {

    @NSManaged var building: String
    @NSManaged var distance: NSNumber
    @NSManaged var info: String?
    @NSManaged var majorID: NSNumber
    @NSManaged var minorID: NSNumber
    @NSManaged var subject: String
    @NSManaged var location: String?
    @NSManaged var navigationDirectories: NSSet

}
