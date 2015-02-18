//
//  InfoViewController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/1/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    var currBeacon:Beacon = Beacon()
    
    @IBOutlet weak var beaconName: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    
    func updateBeacon(beacon:Beacon){
        currBeacon = beacon
        distanceText.text = String(beacon.distance) + " meters"
        beaconName.text = beacon.location
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBeacon(currBeacon)
        
        let stap = UITapGestureRecognizer(target: self, action: Selector("singletap:"))
        stap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(stap)
        
        let dtap = UITapGestureRecognizer(target: self, action: Selector("doubletap:"))
        dtap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(dtap)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let beacon = (self.tabBarController as BeaconTabController).currentBeacon
        updateBeacon(beacon)
    }

    @IBAction func doubletap(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Detected Beacons", sender: self)
    }
    
    func singletap(sender: UITapGestureRecognizer) {
        
    }
}