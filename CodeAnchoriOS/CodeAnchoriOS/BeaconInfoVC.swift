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
    
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var tabController = self.tabBarController! as NIBSTabBarController
        NSLog("%@", tabController.currentBeacon!)
        
        beacon = tabController.currentBeacon
        
        self.title = beacon?.subject
        textArea.text = beacon?.info
        
        textArea.selectable = false;

        distanceLabel.text = "Distance \(beacon!.distance!)m"
        
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

    
    func back(sender: UIBarButtonItem) {
        let tbc = self.tabBarController! as NIBSTabBarController
        tbc.currentBeacon = nil
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}