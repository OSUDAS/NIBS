//
//  BeaconTabController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

let setting = 0
let info = 1
let nav = 2

class BeaconTabController: UITabBarController {
    var currentBeacon:Beacon = Beacon()
    
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
        
        let sright = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        sright.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(sright)
        
        let sleft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        sleft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(sleft)
        
        let dataLoader = DemoDataLoader()
        let beacons = dataLoader.loadData()
        
        //NSLog("TAB BAR LOADED, setting beacon to: \(beacons[0])")
        
        (self.viewControllers![0] as UIViewController).title  = "Settings"
        (self.viewControllers![1] as UIViewController).title  = "Information"
        (self.viewControllers![2] as UIViewController).title  = "Navigation"
        
        let tabs = self.viewControllers! as [UIViewController]
        
        let gear = UIImage(named: "Gear.png")
        tabs[setting].tabBarItem.image = imageWithImage(gear!, newSize: CGSizeMake(30, 30))
        
        let question = UIImage(named: "Questionmark.png")
        tabs[info].tabBarItem.image = imageWithImage(question!, newSize: CGSizeMake(30, 30))
        
        let compass = UIImage(named: "Compass.png")
        tabs[nav].tabBarItem.image = imageWithImage(compass!, newSize: CGSizeMake(30, 30))
        
        currentBeacon = beacons[0]
        
        self.selectedIndex = info
    }
    
    func imageWithImage(image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
