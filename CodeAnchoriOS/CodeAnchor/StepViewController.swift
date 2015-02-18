//
//  StepViewController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/8/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class StepViewController: UIViewController {
    
    var stepnum = 0;
    
    var directory:NavDirectory = NavDirectory() {
        didSet{
            //NSLog("Step directory set to: \(directory)")
            if (self.view.window != nil) {updateUI();}//update ui
        }
    }
    

    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var direction: UITextView!
    @IBOutlet weak var stepcount: UILabel!
    
    @IBAction func exitPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUI(){
        self.navbar.title = directory.location as String
        self.direction.text = directory.steps[stepnum]
        self.stepcount.text = "Step \(stepnum+1)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        //update ui
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.directory = (self.navigationController! as StepsNavController).directory
        
        self.direction.selectable = false
        
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
        if(stepnum < directory.steps.count-1){
            
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
