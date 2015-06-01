//
//  NavigationNC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

//Holds properties to share between the navigation and step view controllers
class NavigationNC: UINavigationController {
    var startBeacon:BeaconObject?
    var destinationBeacon:BeaconObject?
    var intermediateBeacons:[BeaconObject] = [BeaconObject]()
    var manager:DataManager?
    var selectedDirectory:NavigationDirectoryObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = (UIApplication.sharedApplication().delegate as AppDelegate).manager
        var tabVC = self.tabBarController! as NIBSTabBarController
        
        startBeacon = tabVC.currentBeacon
    }
}
