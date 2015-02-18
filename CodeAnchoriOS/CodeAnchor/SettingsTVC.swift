//
//  SettingsTVC.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
