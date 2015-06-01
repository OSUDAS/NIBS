//
//  NibConfig.swift
//  CodeAnchoriOS
//
//  Created by Nathan Woodworth on 4/26/15.
//  Copyright (c) 2015 CodeAnchor. All rights reserved.
//

import Foundation

/*
    Singleton for holding app configuration information
*/
class NibConfig: NSObject {
    var notifications:Bool = true;
    
    override init(){
        super.init()
    }
}
