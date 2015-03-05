//
//  HttpTestViewController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 3/3/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class HttpTestViewController: UIViewController {
    let httpManager = HttpManager()
    
    @IBOutlet weak var minorText: UITextField!
    @IBOutlet weak var majorText: UITextField!
    
    @IBOutlet weak var textArea: UITextView!
    
    @IBAction func exitView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func sendHttp(sender: AnyObject) {
        if(majorText.text.isEmpty || minorText.text.isEmpty){
            httpManager.testQueryBaecon(0, minorID: 0, controller:self)
        }else {
            httpManager.testQueryBaecon(majorText.text.toInt()!, minorID: minorText.text.toInt()!, controller:self)
        }
    }
    
}
