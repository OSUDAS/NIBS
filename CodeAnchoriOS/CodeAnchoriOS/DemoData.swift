//
//  DemoData.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/22/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

//Creates fake data into the database
import UIKit
import CoreData

/*
    Loads demo data from a DemoData file and puts it into the Core Data
*/
class DemoData {
    
    let context = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    let filename = "DemoData"
    
    func loadJsonData() -> NSDictionary{
        
        var error: NSError?
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        var jsonData:NSData = NSData(contentsOfFile: path!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)!
        
        let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments, error: &error) as NSDictionary
        
        return json
    }
    
    func loadDemoData(){
        
        let json = loadJsonData()
        var beacons = [Beacon]()
        
        let beaconArray = json["Demo"] as [NSDictionary]
        
        for beacon in beaconArray{
            
            
            //Query database to check if beacon is already in it
            
            
            let request = NSFetchRequest(entityName: "Beacon");
            request.returnsObjectsAsFaults = false
            let major = beacon.valueForKey("majorID")!.integerValue!
            request.predicate = NSPredicate(format: "majorID == %d", major)
            
            var error:NSError?
            
            let matches = context.executeFetchRequest(request, error: &error)
            
            if(matches == nil || error != nil || matches?.count > 1){
                //TODO handle error
            } else if (matches?.count == 0){ 
        
                
                var newBeacon = NSEntityDescription.insertNewObjectForEntityForName("Beacon", inManagedObjectContext: context) as Beacon
                
                newBeacon.setValue(beacon.valueForKey("majorID"), forKey: "majorID")
                newBeacon.setValue(beacon.valueForKey("minorID"), forKey: "minorID")
                newBeacon.setValue(beacon.valueForKey("building"), forKey: "building")
                newBeacon.setValue(beacon.valueForKey("subject"), forKey: "subject")
                
                if(beacon.objectForKey("location") != nil ){
                    newBeacon.setValue(beacon.valueForKey("location"), forKey: "location")
                }
                
                if(beacon.objectForKey("distance") != nil){
                    newBeacon.setValue(beacon.valueForKey("distance"), forKey: "distance")
                }
                
                if(beacon.objectForKey("info") != nil){
                    newBeacon.setValue(beacon.valueForKey("info"), forKey: "info")
                }
                
                if(beacon.objectForKey("navigation") != nil){
                    let navDirectories = beacon.valueForKey("navigation") as [NSDictionary]
                    
                    for nD in navDirectories {
                        var newDirectory = NSEntityDescription.insertNewObjectForEntityForName("NavigationDirectory", inManagedObjectContext: context) as NavigationDirectory
                        newDirectory.beacon = newBeacon
                        newDirectory.setValue(nD.valueForKey("majorID"), forKey: "toBeaconID")
                        newDirectory.setValue(nD.valueForKey("subject"), forKey: "subject")
                        if(nD.objectForKey("destination") != nil){
                            newDirectory.setValue(nD.valueForKey("destination"), forKey: "destination")
                        }
                        newDirectory.setValue(nD.valueForKey("building"), forKey: "building")
                        
                        if(nD.objectForKey("steps") != nil ){
                            let steps = nD.valueForKey("steps") as [NSDictionary]
                            
                            for s in steps {
                                var newStep = NSEntityDescription.insertNewObjectForEntityForName("Step", inManagedObjectContext: context) as Step
                                newStep.setValue(s.valueForKey("instruction"), forKey: "instruction")
                                newStep.setValue(s.valueForKey("stepNum"), forKey:"stepNum")
                                
                                newStep.navigationDirectory = newDirectory
                                if(s.objectForKey("imageURL") != nil){
                                    newStep.setValue(s.valueForKey("imageURL"), forKey: "imageURL")
                                }
                                if(s.objectForKey("majorID") != nil) {
                                    newStep.setValue(s.valueForKey("majorID"), forKey: "beaconID")
                                }
                            }
                        }
                        
                    }
                }
                
                NSLog("Beacon: %@",newBeacon);
            }
            
            context.save(nil)
            
        }


    }

}
