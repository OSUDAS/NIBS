//
//  BeaconInformationTVC.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class BeaconInformationTVC: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items:[InfoBucket] = [InfoBucket]();
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        items = (self.tabBarController as BeaconTabController).currentBeacon.information as [InfoBucket]
        
        //NSLog("!!!!!Got: \(items)")
        
        self.tableView.reloadData()
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("infocell") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row].subject
        cell.detailTextLabel?.text = self.items[indexPath.row].desc
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //NSLog("User selected row")
        
    }
}
