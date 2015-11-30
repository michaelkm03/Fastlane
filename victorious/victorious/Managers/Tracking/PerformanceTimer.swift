//
//  PerformanceTimer.swift
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class PerformanceEvent: NSObject, NSCoding {
    
    let kTypeKey = "type"
    let kSubtypeKey = "subtype"
    let kDateStartedKey = "dateStarted"
    
    let type: String
    let subtype: String?
    let dateStarted: NSDate
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject( self.type, forKey: kTypeKey)
        aCoder.encodeObject( self.subtype, forKey: kSubtypeKey)
        aCoder.encodeObject( self.dateStarted, forKey: kDateStartedKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let type = aDecoder.decodeObjectForKey(kTypeKey) as? String,
            let dateStarted = aDecoder.decodeObjectForKey(kDateStartedKey) as? NSDate else {
                self.type = ""
                self.dateStarted = NSDate()
                self.subtype = nil
                super.init()
                return nil
        }
        self.type = type
        self.dateStarted = dateStarted
        self.subtype = aDecoder.decodeObjectForKey(kSubtypeKey) as? String
        super.init()
    }
    
    init( type: String, subtype: String?, dateStarted: NSDate ) {
        self.type = type
        self.subtype = subtype
        self.dateStarted = dateStarted
    }
}

class PerformanceTimer: NSObject {
    
    private static let instance = PerformanceTimer()
    
    private var sharedSelf: PerformanceTimer {
        return PerformanceTimer.instance
    }
    
    private static let queue = dispatch_queue_create( "com.getvictorious.PerformanceTimer", DISPATCH_QUEUE_SERIAL )
    private var events = Set<PerformanceEvent>()
    
    private var filepath: String {
        let basePath = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true).first!
        return (basePath as NSString).stringByAppendingPathComponent("performance_tracking.plist")
    }
    
    func startEvent( type: String, subtype: String? ) {
        let dateStarted = NSDate()
        dispatch_async( PerformanceTimer.queue ) {
            let event = PerformanceEvent(type: type, subtype: subtype, dateStarted: dateStarted)
            if let index = self.sharedSelf.events.indexOf(event) {
                self.sharedSelf.events.removeAtIndex( index )
            }
            self.sharedSelf.events.insert( event )
        }
    }
    
    func cancelEvent( type: String, subtype: String? = nil ) {
        dispatch_async( PerformanceTimer.queue ) {
            if let index = self.sharedSelf.events.indexOf({ $0.type == type && $0.subtype == subtype }) {
                self.sharedSelf.events.removeAtIndex( index )
                print( "\n\n >>>> PerformanceTimer :: cancelEvent :: \(type) \(subtype) <<<< \n\n" )
            }
        }
    }
    
    func endEvent( type: String, subtype: String? = nil ) {
        let dateEnded = NSDate()
        dispatch_async( PerformanceTimer.queue ) {
            if let index = self.sharedSelf.events.indexOf({ $0.type == type && $0.subtype == subtype }) {
                let event = self.sharedSelf.events[ index ]
                self.sharedSelf.events.removeAtIndex( index )
                let duration = dateEnded.timeIntervalSinceDate(event.dateStarted)
                print( "\n\n >>>> PerformanceTimer :: endEvent :: \(event.type) \(event.subtype) \(Int(duration * 1000.0)) <<<< \n\n" )
            }
        }
    }
}
