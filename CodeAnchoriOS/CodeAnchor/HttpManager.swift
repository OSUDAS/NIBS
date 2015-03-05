//
//  HttpManager.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 3/3/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import Foundation

class HttpManager : NSObject {
    
    let baseURL = "http://1-dot-capstone-bluetooth.appspot.com/capstone?"
    
    func testQueryBaecon(majorID:Int, minorID:Int, controller:HttpTestViewController){
        
        weak var con = controller;
        
        var requestURL = NSURL(string: baseURL + "majorId=\(majorID)&minorId=\(minorID)")
        
        /* Good for image queries
        var request = NSURLRequest(URL: requestURL!)
        var config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        var session = NSURLSession(configuration: config)
        var downTask = session.downloadTaskWithRequest(request, completionHandler: { (localfile, response, error) -> Void in
            <#code#>
        })*/
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) {(data,response,error) in
            
            if(error == nil){
                dispatch_async(dispatch_get_main_queue() , { () -> Void in
                    con!.textArea.text = NSString(data: data, encoding: NSUTF8StringEncoding)
                    //Send message to bluetooth delegate controller
                })
            } else {
                //TODO handle network errors
                
            }
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))

        }
        
        task.resume()
        
    }
    
    
}
