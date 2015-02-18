//
//  InfoBucket.swift
//  CodeAnchor
//
//  Created by Nathan Woodworth on 2/3/15.
//  Copyright (c) 2015 Nathan Woodworth. All rights reserved.
//

import Foundation

class InfoBucket:NSObject{
    var id:NSInteger = 0
    var subject:String = ""
    var desc:String = ""
    
    override var description: String{
        return "Info{id: \(id), subject: \(subject), desc: \(desc)}"
    }
    
}
