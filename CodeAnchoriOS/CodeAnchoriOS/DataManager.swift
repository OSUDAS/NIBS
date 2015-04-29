//
//  DataManager.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/22/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//
import CoreData
import UIKit



class DataManager: NSObject, ESTBeaconManagerDelegate {
    let beaconManager : ESTBeaconManager = ESTBeaconManager()
    var beaconList = [ESTBeacon]()
    var beaconCache = [BeaconObject]()
    var counter = 0;
    var configuration:NibConfig = NibConfig()
    var notificationTimeOut = [Int]()
    var timeoutTimer:NSTimer?
    
    //Listen for beacons
    //Check Cache if beacons are there
    //If not, check database if beacons are there
    //If not, query network for beacons
    
    func run() {
        
        //TODO changed to 30+ seconds, only set to 10 seconds for testing
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("clearTimeout:"), userInfo: nil, repeats: true)
        
        //Load configuration
        loadConfiguration()
        
        
        NSLog("DataManager is running");
        
        beaconManager.delegate = self
        var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "CodeAnchorRegion")
        
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            NSLog("location is not authorized")
            
            beaconManager.requestWhenInUseAuthorization()
            
        } else {
            
            NSLog("location is authorized");
            
        }
        
        //FOR DEMOING
        //Load database beacons
        loadAllBeacons()
        
        //TODO Remove this for release
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            beaconManager.startRangingBeaconsInRegion(beaconRegion)
        }
        
       

    }
    
    func clearTimeout(timer:NSTimer){
        notificationTimeOut = [Int]()
    }
    
    func loadConfiguration(){
        let configs = NibConfig()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("notifications") == nil){
            defaults.setObject(true, forKey: "notifications")
            configs.notifications = true
            NSLog("Creating notification in defaults")
        } else {
            let setting = defaults.objectForKey("notifications") as Bool
            configs.notifications = setting
            NSLog("Setting notifications to: \(setting)")
        }
        configuration = configs
    }
    
    func loadAllBeacons(){
        let request = NSFetchRequest(entityName: "Beacon");
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "majorID != %d", -1)
        
        var error:NSError?
        
        let matches = context.executeFetchRequest(request, error: &error)
        
        if(matches == nil || error != nil){
            //NSLog("Error with matches")
        } else if (matches?.count > 0){ //TODO use Beacon instead of BeaconObject in tables
            let beacons = matches as [Beacon]
            
            for beacon in beacons{
                insertBeaconIntoCache(beacon)
            }
            
        }

    }
    
    func updateCache(eBeacon: ESTBeacon) -> BeaconObject?{
        
        var beaconToUpdate = beaconCache.filter({$0.majorID == eBeacon.major})
        
        if(beaconToUpdate.isEmpty) {
            NSLog("Beacon: major: \(eBeacon.major) minor: \(eBeacon.minor)")
            NSLog("Could not find beacons in \(beaconToUpdate) in cache: \(beaconCache) with ID: \(eBeacon.major)")
            return nil}
        
        var beacon = beaconToUpdate.first
        
        if(eBeacon.distance.integerValue < -1){
            beacon?.distance = 0
        } else {
            beacon?.distance = eBeacon.distance
        }
    
        return beacon;
    }
    
    
    func insertBeaconIntoCache(beacon: Beacon) {
        beaconCache.append(BeaconObject(beacon:beacon, includeNav: true))
    }
    
    //Beacon Manager Delegate Methods
    func beaconManager(manager: ESTBeaconManager!, didRangeBeacons beacons: [ESTBeacon]!, inRegion region: ESTBeaconRegion!) {
        println("I've found \(beacons.count) beacons in range")
        beaconList = beacons
        //Check if in Cache/update distance
        
        for eBeacon in beacons!{
            
            /*
            var power:ESTBeaconPower = .Level8
            
            eBeacon.writePower(power, completion: {(value: ESTBeaconPower, error: NSError!) in
                //
                    //NSLog("Error: \(error)")
                    //NSLog("Power set to: \(value)")
                }
            )*/
            
            var cached = updateCache(eBeacon)
            if(cached == nil){
                //Check if beacon is in the database
                var beacon = queryDatabase(eBeacon.major.integerValue, minorID: eBeacon.minor.integerValue)
                
                if(beacon == nil){
                    //NSLog("majorID: \(eBeacon.major) minorID: \(eBeacon.minor)")
                    //Query the beacon on the network
                    //queryNetwork(eBeacon.major.integerValue, minorID: beacons!.first!.minor.integerValue)
                    
                } else { //Beacon in Database
                    
                    //Insert into cache
                    NSLog("Inserting new beacon into cache?")
                    insertBeaconIntoCache(beacon!)
                }
            } else {
                
                if(configuration.notifications){
                    //Notify user if not timedout
                    if let index = find (notificationTimeOut, eBeacon.major.integerValue){
                    } else {
                        //Notify beacons detected
                        //Set up notificaitons
                        var localNotification:UILocalNotification = UILocalNotification()
                        localNotification.alertAction = "Beacon notification"
                        
                        localNotification.alertBody = "\(cached!.subject!) Beacon nearby"
                        
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        localNotification.category = "beaconNotification"
                        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                        
                        notificationTimeOut.append(cached!.majorID!.integerValue)
                    }
                }
            }

        }
        
    }
    
    
    
    func beaconManager(manager: ESTBeaconManager!, didDiscoverBeacons beacons: [ESTBeacon]!, inRegion region: ESTBeaconRegion!) {
        NSLog("Discovered Beacons!");
        beaconList = beacons
        //self.tableView.reloadData()
    }
    
    
    func beaconManager(manager: ESTBeaconManager!, didFailDiscoveryInRegion region: ESTBeaconRegion!) {
        NSLog("Discovery failed");
    }
    
    func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        NSLog("Ranging Failed \(error)");
    }
    
    
    //Database Functionality
    
    let context = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    func queryDatabase(majorID:Int, minorID:Int) -> Beacon?{
        
        var beacon:Beacon? = nil;
        
        let request = NSFetchRequest(entityName: "Beacon");
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "majorID == %d", majorID) //TODO minorID
        
        var error:NSError?
        
        let matches = context.executeFetchRequest(request, error: &error)
        
        if(matches == nil || error != nil || matches?.count > 1){
            //TODO handle error
        } else if (matches?.count > 0){ //TODO use Beacon instead of BeaconObject in tables
            let dataBeacon:Beacon = matches?.first as Beacon
            
            beacon = dataBeacon
            //Format to BeaconObject
        } else {
            //no matches found, return nil
            return nil;
        }
        
        return beacon;
    }

    
    
    //Network Functionality
    let baseURL = "http://1-dot-bluetooth-cs463.appspot.com/capstone?"
    
    func queryNetwork(majorID:Int, minorID:Int){
        
        NSLog("Querying Network for majorID: %d",majorID)
        var requestURL = NSURL(string: baseURL + "majorId=\(majorID)&minorId=\(minorID)")
        
        NSLog("Sending HTTP Request to : %@",requestURL!)
        
        weak var weakself = self
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) {(data,response,error) in
            
            if(error == nil){
                //TODO Change dispatch to the current background queue
                dispatch_async(dispatch_get_main_queue() , { () -> Void in
                    
                    weakself!.recievedData(NSString(data: data, encoding: NSUTF8StringEncoding)!)
                    //Send message to bluetooth delegate controller
                })
            } else {
                //TODO handle network errors
                NSLog("Error: %@", error)
            }
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
        }
        
        task.resume()
    }
    
    func insertBeaconIntoDatabase(data: NSString) -> Beacon?{
        
        var dict = data.dataUsingEncoding(NSUTF8StringEncoding)
        var beacon = NSJSONSerialization.JSONObjectWithData(dict!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        NSLog("Data: %@",beacon);
        
        if(beacon.count == 0){
            NSLog("Error: EMPTY");
            return nil;
        }
        
        var newBeacon = NSEntityDescription.insertNewObjectForEntityForName("Beacon", inManagedObjectContext: context) as Beacon
        
        newBeacon.setValue(beacon.valueForKey("majorId")!.integerValue, forKey: "majorID")
        newBeacon.setValue(beacon.valueForKey("minorId")!.integerValue, forKey: "minorID")
        newBeacon.setValue(beacon.valueForKey("building"), forKey: "building")
        newBeacon.setValue(beacon.valueForKey("subject"), forKey: "subject")
        newBeacon.setValue(beacon.valueForKey("info"), forKey: "info")
        
        //TODO Create navigation and steps involved
        
        context.save(nil)
        
        return newBeacon as Beacon

    }
    
    func recievedData(data: NSString){
        NSLog("Recieved data: %@", data)
        //Record in database and put in cache
        var beacon = insertBeaconIntoDatabase(data)
        if(beacon == nil){
            NSLog("Error: No beacon found from data")
            return;
        }
        insertBeaconIntoCache(beacon!)
        
        //Notify
        
    }
    
    func getBeaconWithMajorID(majorID: Int) -> BeaconObject?{
        var beaconToUpdate = beaconCache.filter({$0.majorID == majorID})

        return beaconToUpdate.first
        
    }
}
