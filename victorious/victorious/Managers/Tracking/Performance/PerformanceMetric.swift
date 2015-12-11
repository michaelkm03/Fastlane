//
//  PerformanceMetric.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An object that represents an aspect of the application that participates in
/// tracking app times for performance and latency.  
class PerformanceMetric: NSObject, NSCoding {
    let startEvent: String
    let endEvent: String
    let type: String
    let subtype: String?
    
    init(startEvent: String, endEvent: String, type: String, subtype: String? = nil) {
        self.startEvent = startEvent
        self.endEvent = endEvent
        self.type = type
        self.subtype = subtype
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let startEvent = aDecoder.decodeObjectForKey("startEvent") as? String,
            let endEvent = aDecoder.decodeObjectForKey("endEvent") as? String,
            let type = aDecoder.decodeObjectForKey("type") as? String else {
                abort()
        }
        self.startEvent = startEvent
        self.endEvent = endEvent
        self.type = type
        self.subtype = aDecoder.decodeObjectForKey("subtype") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(type, forKey:"type")
        aCoder.encodeObject(subtype ?? "", forKey:"subtype")
        aCoder.encodeObject(endEvent, forKey:"endEvent")
        aCoder.encodeObject(startEvent, forKey:"startEvent")
    }
}
