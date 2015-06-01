//
//  SettingsTVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/26/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

//View Controller for the settings panel in the app
class SettingsTVC: UITableViewController, UITableViewDelegate {
    
    @IBOutlet weak var distanceSegment: UISegmentedControl!
    @IBOutlet weak var notificationToggle: UISwitch!
    @IBOutlet weak var toneSegment: UISegmentedControl!
    
    var manager:DataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = (UIApplication.sharedApplication().delegate as AppDelegate).manager
        manager?.loadConfiguration()
        NSLog("Config state: \(manager!.configuration.notifications)")
        
        notificationToggle.setOn(manager!.configuration.notifications, animated: false)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if(defaults.objectForKey("tone") == nil){
            defaults.setValue(2, forKey: "tone")
        }
        
        toneSegment.selectedSegmentIndex = defaults.valueForKey("tone")!.integerValue
        
    }
    
    @IBAction func toggleTones(sender: UISegmentedControl) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(sender.selectedSegmentIndex , forKey: "tone")
        
    }
    
    @IBAction func toggleNotifications(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(sender.on, forKey: "notifications")
        manager?.configuration.notifications = sender.on
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0: return "Distance"
        case 1: return "Notifications"
        case 2: return "Navigation Distance Signal"
        default: return ""
        }
        
        
    }
}

  