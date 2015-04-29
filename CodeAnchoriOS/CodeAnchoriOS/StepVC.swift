//
//  StepVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit
import AudioToolbox

class BeaconDistance: NSObject {
    var step:Int = -1
    var id:Int = 0
    var distance:Float = -1
}

class StepVC: UIViewController {
    
    let MAX_SECONDS_INTERVAL = 5.0
    
    var stepnum = 0
    var interval = 1.0
    var location = 0
    var directory:NavigationDirectoryObject?
    var beacons:[BeaconDistance] = [BeaconDistance]()
    var timer:NSTimer?
    var manager:DataManager?
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var directionText: UITextView!
    
    func updateUI(){
        //self.title = directory?.destination
        self.directionText.text = directory!.steps![stepnum].instruction
        self.stepLabel.text = "Step \(stepnum+1)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        //update ui
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("updateBeaconDistance:"), userInfo: nil, repeats: true)
        
        let navNC = self.navigationController! as NavigationNC
        directory = navNC.selectedDirectory
        
        directory?.steps?.sort({ $0.stepNum!.integerValue < $1.stepNum!.integerValue})
        
        //Get List of beacons from steps
        var count = 0
        if(directory != nil){
            beacons = [BeaconDistance]()
            for s in directory!.steps! {
                if(s.beaconID != nil){
                    var beacon = BeaconDistance()
                    beacon.step = count
                    count++
                    beacon.id = s.beaconID!.integerValue
                    beacons.append(beacon)
                }
            }
        }
        
        determineIntervals()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        
    }
    
    func determineIntervals(){
        //Interval times from 5.0 to 0.1
        let count:Double = Double(beacons.count) + 1.0
        interval = count/MAX_SECONDS_INTERVAL
    }
    
    func determineLocation() -> Int{
        var beacons_copy = beacons
        
        beacons_copy.sort { $0.distance < $1.distance }
        
        var beacon1:BeaconDistance?
        var beacon2:BeaconDistance?
        for b in beacons_copy {
            if(b.distance == -1 || b.distance == 0){
                continue
            }
            if(beacon1 == nil){
                beacon1 = b
            } else if(beacon2 == nil){
                beacon2 = b
            }
        }
        
        if(beacon1==nil && beacon2==nil){
            return 0
        }
        
        if(beacon1 != nil && beacon2 != nil){
            
            if(beacon1!.step > beacon2!.step){
                return beacon1!.step
            } else {
                return beacon2!.step
            }
        }
        
        if(beacon1!.step+1 == beacons.count){ //Destination beacon is the closest
            return beacon1!.step + 1
        }
        
        return beacon1!.step
    }
    
    func updateBeaconDistance(timer:NSTimer){
        
        let newLocation = determineLocation()
        if(newLocation > location){
            //Set new timer interval
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        
        
        for beacon in beacons{
            var b = manager?.getBeaconWithMajorID(beacon.id)
            if(b != nil){
                beacon.distance = b!.distance!.floatValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = (UIApplication.sharedApplication().delegate as AppDelegate).manager
        
        
        let navNC = self.navigationController! as NavigationNC
        directory = navNC.selectedDirectory
        
        directory?.steps?.sort({ $0.stepNum!.integerValue < $1.stepNum!.integerValue})
        
        //Get List of beacons from steps
        var count = 0
        if(directory != nil){
            beacons = [BeaconDistance]()
            for s in directory!.steps! {
                if(s.beaconID != nil){
                    var beacon = BeaconDistance()
                    beacon.step = count
                    count++
                    beacon.id = s.beaconID!.integerValue
                    beacons.append(beacon)
                }
            }
        }
       
        determineIntervals()
        
        self.title = directory?.destination
        
        //self.direction.selectable = false
        
        let stap = UITapGestureRecognizer(target: self, action: Selector("singletap:"))
        stap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(stap)
        
        let dtap = UITapGestureRecognizer(target: self, action: Selector("doubletap:"))
        dtap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(dtap)
        
        let sright = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        sright.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(sright)
        
        let sleft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        sleft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(sleft)
        
        
    }
    
    
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        if(stepnum < directory!.steps!.count-1){
            
            UIView.transitionWithView(self.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                self.stepnum++
                self.updateUI()
                }, completion: nil)
            
        }
    }
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        if(stepnum > 0){
            
            
            UIView.transitionWithView(self.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                self.stepnum--
                self.updateUI()
                }, completion: nil)
            
            
        }
        
    }
    
    
    @IBAction func doubletap(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func singletap(sender: UITapGestureRecognizer){
        
    }

}
