//
//  BeaconTableViewController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class BeaconTableViewController : UITableViewController{
    
    var items:[Beacon] = [Beacon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loader = DemoDataLoader()
        
        items = loader.loadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("beaconcell") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row].location
        cell.detailTextLabel?.text = self.items[indexPath.row].building
        
        return cell
    }
    @IBAction func exitPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        (self.presentingViewController! as BeaconTabController).currentBeacon = items[indexPath.row]
        self.dismissViewControllerAnimated(true , completion: nil)
        
    }
}
