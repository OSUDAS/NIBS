//
//  BeaconInfoTV.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

class BeaconInfoVC: UIViewController {
    var beacon:BeaconObject?
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //Timer for when to refresh the distance label for the given beacon
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get current beacon selected
        var tabController = self.tabBarController! as NIBSTabBarController
        beacon = tabController.currentBeacon
        
        //Setup UI
        self.title = beacon?.subject
        textArea.text = beacon?.info
        textArea.selectable = false;
        distanceLabel.text = "Distance \(beacon!.distance!)m"
        
        //Create back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Beacons", style: UIBarButtonItemStyle.Bordered, target: self, action :"back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    override func viewWillAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateUI:"), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer?.invalidate()
    }
    
    func updateUI(timer:NSTimer){
        if(beacon != nil){
            distanceLabel.text = "Distance \(beacon!.distance!)m"
        }
        
    }

    //Back button pressed
    func back(sender: UIBarButtonItem) {
        let tbc = self.tabBarController! as NIBSTabBarController
        tbc.currentBeacon = nil
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}