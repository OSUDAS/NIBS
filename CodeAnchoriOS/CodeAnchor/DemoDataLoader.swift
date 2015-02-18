//
//  DemoDataLoader.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/3/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import Foundation

class DemoDataLoader:NSObject {
    
    func loadJsonData() -> NSDictionary{
        
        var error: NSError?
        
        let path = NSBundle.mainBundle().pathForResource("DemoData", ofType: "json")
        var jsonData:NSData = NSData(contentsOfFile: path!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)!
        
        let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments, error: &error) as NSDictionary

        return json
    }
    
    func loadData() -> [Beacon]{
        
        let json = loadJsonData()
        var beacons = [Beacon]()
        
        let beaconArray = json["Demo"] as [NSDictionary]
        
        for beacon in beaconArray{
            var b = Beacon()
            let ids:String = "majorId"
            b.majorID = beacon.valueForKey("majorID") as Int
            b.minorID = beacon.valueForKey("minorID") as Int
            
            b.building = beacon.valueForKey("building") as String
            b.location = beacon.valueForKey("location") as String
            
            var binfo = [InfoBucket]()
            let information = beacon.valueForKey("information") as [NSDictionary]
            for info in information{
                var i = InfoBucket()
                i.id = info.valueForKey("id") as Int
                i.subject = info.valueForKey("subject") as String
                i.desc = info.valueForKey("description") as String
                binfo.append(i)
            }
            
            b.information = binfo
            
            var bnav = [NavDirectory]()
            let navigation = beacon.valueForKey("navigation") as [NSDictionary]
            for nav in navigation{
                var n = NavDirectory()
                n.majorID = nav.valueForKey("majorID") as Int
                n.minorID = nav.valueForKey("minorID") as Int
                n.location = nav.valueForKey("location") as String

                let steps = nav.valueForKey("steps") as [NSDictionary]
                
                for step in steps{
                    n.steps.append(step.valueForKey("step") as String)
                }
                
                bnav.append(n)
                
            }
            
            b.navigation = bnav
            
           beacons.append(b)
            
        
        }
        

        
        
        
        return beacons
    }
    
    
}
