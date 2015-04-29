//
//  NavDirectoryTVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

class NavDirectoryTVC: UITableViewController {
    
    
    var items:[NavigationDirectoryObject] = [NavigationDirectoryObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var tbc = self.tabBarController as NIBSTabBarController
        
        if(tbc.currentBeacon != nil) {
            items = tbc.currentBeacon!.navigationDirectories!
        } else {
            items = [NavigationDirectoryObject]()
        }
        
        
        //NSLog("!!!!!Got: \(items)")
        
        self.tableView.reloadData()
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("NavigationCell") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row].destination
        cell.detailTextLabel?.text = self.items[indexPath.row].subject
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let nnc = self.navigationController as NavigationNC
        nnc.selectedDirectory = items[indexPath.row]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Send selected Directory to StepVC
        if( segue.identifier == "Show Steps"){
            
            let selectedRowIndex = self.tableView.indexPathForSelectedRow()
            //NSLog("Sending nav of \(self.items[selectedRowIndex!.row])")
            
            let stepVC:StepVC = segue.destinationViewController as StepVC
            
            stepVC.directory = self.items[selectedRowIndex!.row]
        }
    }

}