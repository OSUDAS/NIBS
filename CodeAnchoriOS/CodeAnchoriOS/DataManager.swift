//
//  DataManager.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/22/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//
import CoreData
import UIKit

//Listen for beacons
//Check Cache if beacons are there
//If not, check database if beacons are there
//If not, query network for beacons
class DataManager: NSObject, ESTBeaconManagerDelegate {
    let beaconManager : ESTBeaconManager = ESTBeaconManager()
    var beaconList = [ESTBeacon]()
    var beaconCache = [BeaconObject]()
    var counter = 0;
    var configuration:NibConfig = NibConfig()
    var notificationTimeOut = [Int]()
    var timeoutTimer:NSTimer?
    
    
    
    /*
        Initializes the Data Manager and starts the Estimote SDK iBeacon scanning.
    */
    func run() {
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
        
        //Load demo data into database beacons
        loadAllBeacons()
        
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            beaconManager.startRangingBeaconsInRegion(beaconRegion)
        }

    }
    
    /*
        Resets the timeout for collecting data for beacons over the network
    */
    func clearTimeout(timer:NSTimer){
        notificationTimeOut = [Int]()
    }
    
    /*
        Reads in NSUserDefaults into a NibConfig Singleton
    */
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
    
    /*
        Places all beacons within Core Data into the cache
    */
    func loadAllBeacons(){
        let request = NSFetchRequest(entityName: "Beacon");
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "majorID != %d", -1)
        
        var error:NSError?
        
        let matches = context.executeFetchRequest(request, error: &error)
        
        if(matches == nil || error != nil){
            NSLog("Error with matches: \(error)")
        } else if (matches?.count > 0){
            let beacons = matches as [Beacon]
            
            for beacon in beacons{
                insertBeaconIntoCache(beacon)
            }
            
        }

    }
    
    /*
        Updates the distance measurement of the beacon within the cache
    */
    func updateCache(eBeacon: ESTBeacon) -> BeaconObject?{
        
        var beaconToUpdate = beaconCache.filter({$0.majorID == eBeacon.major})
        
        if(beaconToUpdate.isEmpty) {
            return nil
        }
        
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
        beaconList = beacons
        //Check if in Cache/update distance
        
        for eBeacon in beacons!{
            
            var cached = updateCache(eBeacon)
            if(cached == nil){
                //Check if beacon is in the database
                var beacon = queryDatabase(eBeacon.major.integerValue, minorID: eBeacon.minor.integerValue)
                
                if(beacon == nil){
                    //Query the beacon on the network
                    queryNetwork(eBeacon.major.integerValue, minorID: beacons!.first!.minor.integerValue)
                    
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
    }
    
    func beaconManager(manager: ESTBeaconManager!, didFailDiscoveryInRegion region: ESTBeaconRegion!) {
        NSLog("Discovery failed");
    }
    
    func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        NSLog("Ranging Failed \(error)");
    }
    
    
    //Database Functionality
    
    let context = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    /*
        Returns a Beacon in the database if it exists
    */
    func queryDatabase(majorID:Int, minorID:Int) -> Beacon?{
        
        var beacon:Beacon? = nil;
        
        let request = NSFetchRequest(entityName: "Beacon");
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "majorID == %d", majorID) //TODO minorID
        
        var error:NSError?
        
        let matches = context.executeFetchRequest(request, error: &error)
        
        if(matches == nil || error != nil || matches?.count > 1){
            NSLog("Error: \(error)")
        } else if (matches?.count > 0){ //TODO use Beacon instead of BeaconObject in tables
            let dataBeacon:Beacon = matches?.first as Beacon
            
            beacon = dataBeacon
        } else {
            //no matches found, return nil
            return nil;
        }
        
        return beacon;
    }

    
    
    //Network Functionality
    let baseURL = "http://1-dot-bluetooth-cs463.appspot.com/capstone?"
    
    /*
        Initializes a network task to gather data fro a given major and minor ID
    */
    func queryNetwork(majorID:Int, minorID:Int){
        
        var requestURL = NSURL(string: baseURL + "majorId=\(majorID)&minorId=\(minorID)")
        weak var weakself = self
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) {(data,response,error) in
            
            if(error == nil){
                dispatch_async(dispatch_get_main_queue() , { () -> Void in
                    
                    weakself!.recievedData(NSString(data: data, encoding: NSUTF8StringEncoding)!)
                })
            } else {
                NSLog("Error: %@", error)
            }
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
        }
        
        task.resume()
    }
    
    func insertBeaconIntoDatabase(data: NSString) -> Beacon?{
        
        var dict = data.dataUsingEncoding(NSUTF8StringEncoding)
        var beacon = NSJSONSerialization.JSONObjectWithData(dict!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
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
        
        context.save(nil)
        
        return newBeacon as Beacon

    }
    
    /*
        Callback method for a network call that data has been recieved and ready to input into the database
    */
    func recievedData(data: NSString){
        //Record in database and put in cache
        var beacon = insertBeaconIntoDatabase(data)
        if(beacon == nil){
            NSLog("Error: No beacon found from data")
            return;
        }
        insertBeaconIntoCache(beacon!)
        
    }
    
    func getBeaconWithMajorID(majorID: Int) -> BeaconObject?{
        var beaconToUpdate = beaconCache.filter({$0.majorID == majorID})

        return beaconToUpdate.first
        
    }
}
