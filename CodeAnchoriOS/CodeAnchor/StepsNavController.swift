//
//  StepsNavController.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/10/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import UIKit

class StepsNavController: UINavigationController {
    var directory:NavDirectory = NavDirectory() {
        didSet{
            self.title = directory.location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = directory.location
    }

}