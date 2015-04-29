//
//  NavigationDirectory.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation
import CoreData

@objc(NavigationDirectory)
class NavigationDirectory: NSManagedObject {

    @NSManaged var toBeaconID: NSNumber
    @NSManaged var building: String?
    @NSManaged var subject: String?
    @NSManaged var destination: String?
    @NSManaged var beacon: Beacon
    @NSManaged var steps: NSSet

}
