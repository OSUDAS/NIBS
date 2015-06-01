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
        
        //Register gestures
        let sright = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        sright.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(sright)
        
        let sleft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        sleft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(sleft)
        
        //Set tab names
        (self.viewControllers![0] as UIViewController).title  = "Settings"
        (self.viewControllers![1] as UIViewController).title  = "Information"
        (self.viewControllers![2] as UIViewController).title  = "Navigation"
        
        let tabs = self.viewControllers! as [UIViewController]
        
        let beacons = manager?.beaconCache

        //Start timer for updating the current beacons distance
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("updateBeaconDistance:"), userInfo: nil, repeats: true)
        
    }
    
    func updateBeaconDistance(timer: NSTimer){
        if(self.currentBeacon != nil){
            var updatedBeacon = manager!.getBeaconWithMajorID(currentBeacon!.majorID!.integerValue)
            if(updatedBeacon == nil){
                currentBeacon!.distance = 0
            } else {
                currentBeacon = updatedBeacon
            }
        }
    }
    
    //Resizes an image into the correct size for the tab bar item
    func imageWithImage(image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
