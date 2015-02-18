//
//  BeaconNavigationTVC.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class BeaconNavigationTVC : UITableViewController, UITableViewDataSource, UITableViewDelegate{
    
    var items:[NavDirectory] = [NavDirectory]()
    var selecteddir = NavDirectory()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        items = (self.tabBarController as BeaconTabController).currentBeacon.navigation as [NavDirectory]
        
        //NSLog("!!!!!Got: \(items)")
        
        self.tableView.reloadData()
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("navcell") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row].location
        cell.detailTextLabel?.text = self.items[indexPath.row].building
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if( segue.identifier == "Show Steps"){
            
            let selectedRowIndex = self.tableView.indexPathForSelectedRow()
            //NSLog("Sending nav of \(self.items[selectedRowIndex!.row])")
            
            let stepVC:StepsNavController = segue.destinationViewController as StepsNavController
            
            stepVC.directory = self.items[selectedRowIndex!.row]
        }
    }
    
}
