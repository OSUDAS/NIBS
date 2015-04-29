//
//  NIBSTabViewController.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit

let setting = 0
let info = 1
let nav = 2

class NIBSTabBarController : UITabBarController {
    
    var currentBeacon:BeaconObject? 
    var manager:DataManager?
    var timer:NSTimer?
    //var counter = 0
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        
        if(self.selectedIndex > 0){
            let fromView = self.selectedViewController?.view
            let toView = (self.viewControllers![self.selectedIndex - 1] as UIViewController).view
            
            UIView.transitionFromView(fromView!, toView: toView!, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (finished:Bool) -> Void in
                if (finished) {
                    
                    self.selectedIndex--
                }
            })
        }
        
    }
    
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        
        if(self.selectedIndex < 2){
            let fromView = self.selectedViewController?.view
            let toView = (self.viewControllers![self.selectedIndex + 1] as UIViewController).view
            
            UIView.transitionFromView(fromView!, toView: toView!, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { (finished:Bool) -> Void in
                if (finished) {
                    
                    self.selectedIndex++
                }
            })
            
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = (UIApplication.sharedApplication().delegate as AppDelegate).manager
        
        let sright = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        sright.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(sright)
        
        let sleft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        sleft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(sleft)
        
        
        //NSLog("TAB BAR LOADED, setting beacon to: \(beacons[0])")
        
        (self.viewControllers![0] as UIViewController).title  = "Settings"
        (self.viewControllers![1] as UIViewController).title  = "Information"
        (self.viewControllers![2] as UIViewController).title  = "Navigation"
        
        let tabs = self.viewControllers! as [UIViewController]
        
        let beacons = manager?.beaconCache
        
        /*
        let gear = UIImage(named: "Gear.png")
        tabs[setting].tabBarItem.image = imageWithImage(gear!, newSize: CGSizeMake(30, 30))
        
        let question = UIImage(named: "Questionmark.png")
        tabs[info].tabBarItem.image = imageWithImage(question!, newSize: CGSizeMake(30, 30))
        
        let compass = UIImage(named: "Compass.png")
        tabs[nav].tabBarItem.image = imageWithImage(compass!, newSize: CGSizeMake(30, 30))
        */

        //Start timer
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("updateBeaconDistance:"), userInfo: nil, repeats: true)
        
        //self.selectedIndex = info
        
        
        
        
    }
    
    func updateBeaconDistance(timer: NSTimer){
        
        /* Test Notification
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications"
        
        localNotification.alertBody = "Updating cache \(counter)"
        
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "beaconNotification"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
        
        counter++
        */
        
        //NSLog("Updating current Beacon")
        if(self.currentBeacon != nil){
            var updatedBeacon = manager!.getBeaconWithMajorID(currentBeacon!.majorID!.integerValue)
            if(updatedBeacon == nil){
                currentBeacon!.distance = 0
            } else {
                currentBeacon = updatedBeacon
            }
        }
    }
    
    func imageWithImage(image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
