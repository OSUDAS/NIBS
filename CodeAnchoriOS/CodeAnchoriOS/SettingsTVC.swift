//
//  SettingsTVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/26/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

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

  