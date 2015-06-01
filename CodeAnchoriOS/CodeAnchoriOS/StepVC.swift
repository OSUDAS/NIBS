//
//  StepVC.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/25/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class BeaconDistance: NSObject {
    var step:Int = -1
    var id:Int = 0
    var distance:Float = -1
}

class StepVC: UIViewController {
    
    let MAX_SECONDS_INTERVAL:Double =  4.5
    
    var stepnum = 0
    var interval = 1.0
    var location = 0
    var directory:NavigationDirectoryObject?
    var beacons:[BeaconDistance] = [BeaconDistance]()
    var timer:NSTimer?
    var buzzTimer:NSTimer?
    var manager:DataManager?
    var setTone:Int = 2
    
    var audioPlayer = AVAudioPlayer()
    var sound:NSURL?
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var directionText: UITextView!
    
    func updateUI(){
        self.directionText.text = directory!.steps![stepnum].instruction
        self.stepLabel.text = "Step \(stepnum+1)"
    }
    
    //Get the user selected tone type: Tone, Buzz, None
    func checkSetTone(){
        let defaults = NSUserDefaults.standardUserDefaults()
        setTone = defaults.valueForKey("tone")!.integerValue
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkSetTone()
        updateUI()
        
        //Set timer to adjust the speed of the tone
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateBeaconDistance:"), userInfo: nil, repeats: true)
        adjustNotificationTimer(0)
        
        //Get the steps from the navigation directory
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
        buzzTimer?.invalidate()
        
    }
    
    func determineIntervals(){
        //Interval times from 4.0 to 0.1
        let count:Double = Double(beacons.count) + 1.0
        interval = count/MAX_SECONDS_INTERVAL
    }
    
    //Determines which interval the user is in between given the beacon distances
    func determineLocation() -> Int{
        var beacons_copy = beacons

        beacons_copy.sort { $0.distance < $1.distance }
        
        for b in beacons_copy{
            NSLog("beacon \(b.step) distance \(b.distance)")
        }
        
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
        
        if(beacon1!.step == 0 && beacon2 == nil){
            return 0;
        }
        
        if(beacon1!.step+1 == beacons.count){ //Destination beacon is the closest
            return beacon1!.step + 1
        }
        
        if(beacon1 != nil && beacon2 != nil){
            return beacon1!.step+1
        }

        return beacon1!.step
    }
    
    //Changes the speed of the tones or buzzes
    func adjustNotificationTimer(location: Int){
        buzzTimer?.invalidate()
        var inter:Double = Double(location) * interval
        var time:Double = MAX_SECONDS_INTERVAL - inter
        buzzTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("buzz:"), userInfo: nil, repeats: true)
    }
    
    //Produces a tone or buzz
    func buzz(timer:NSTimer){
        
        //TODO: Change the numbers into an enum
        switch setTone
        {
        case 0:
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            break
        case 1:
            AudioServicesPlayAlertSound(SystemSoundID(1))
            
            self.audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: nil)
            audioPlayer.play()
        default:
            break
        }
        
    }
    
    //Fetches the distance collected by the Data Manager for each beacon
    func updateBeaconDistance(timer:NSTimer){
        
        let newLocation = determineLocation()
        if(newLocation != location){
            adjustNotificationTimer(newLocation)
        }
        
        location = newLocation;
        
        //Set the new distances to the beacons from the Data Manager
        for beacon in beacons{
            var b = manager?.getBeaconWithMajorID(beacon.id)
            if(b != nil){
                beacon.distance = b!.distance!.floatValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep", ofType: "wav")!)
        
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
       
        self.title = directory?.destination
        
        //Set up gesture Recognition
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
        //Do nothing, needs to be here for double tap gesture recognition
    }

}
