//
//  BeaconTVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/17/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

/*
*   Shows a table of all beacons detected and ordered by closest beacon detected.
*   Queries BeaconManager for current set of detected beacons.
*   Once a Beacon is selected, it sets the current beacon in the TabController of the selected.
*   Once a Beacon is selected, it displays the beacon information and is only sent back to the list
*       of detected beacons once the back button is pressed or the app is closed.
*/
class BeaconTVC: UITableViewController {
    
    //All Detected Beacons Table
    var items:[BeaconObject] = [BeaconObject]()
    var manager:DataManager?
    var timer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Query BeaconManager for current set of beacons
        manager = (UIApplication.sharedApplication().delegate as AppDelegate).manager
        let beacons = manager!.beaconCache
        items = filterIntermediateBeacons(beacons)
    }
    
    func updateTable(timer: NSTimer){
        let beacons = manager!.beaconCache
        items = filterIntermediateBeacons(beacons)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    override func viewWillAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("updateTable:"), userInfo: nil, repeats: true)
    }
    
    func filterIntermediateBeacons(items: [BeaconObject]) -> [BeaconObject]{
        var good = [BeaconObject]()
        for i in 0...items.endIndex-1{
            if(items[i].subject != "Intermediate"){
                good.append(items[i])
            }
        }
        return good
        
    }
}

//TableViewController Delegate Methods
extension BeaconTVC: UITableViewDelegate, UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("BeaconCell") as UITableViewCell
        
        if(self.items[indexPath.row].subject != ""){
            cell.textLabel?.text = self.items[indexPath.row].location
        }
        cell.detailTextLabel?.text = self.items[indexPath.row].building
        
        return cell
    }
    
    //Row Selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tabController = self.tabBarController! as NIBSTabBarController
        tabController.currentBeacon = items[indexPath.row]
        
    }
}
