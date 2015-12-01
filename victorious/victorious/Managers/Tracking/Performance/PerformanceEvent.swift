//
//  PerformanceEvent.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

struct PerformanceEvent: Hashable {
    let name: String
    let userInfo: String?
    
    let date = NSDate()
    
    var hashValue: Int {
        return name.hashValue
    }
}

func ==(lhs: PerformanceEvent, rhs: PerformanceEvent) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
