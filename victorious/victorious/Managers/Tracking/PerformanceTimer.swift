//
//  PerformanceTimer.swift
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

func ==(lhs: PerformanceEvent, rhs: PerformanceEvent) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct PerformanceEvent: Hashable {
    let type: String
    let subtype: String?
    let date = NSDate()
    
    init( type: String, subtype: String? ) {
        self.type = type
        self.subtype = subtype
    }
    
    var hashValue: Int {
        return self.type.hashValue
    }
}

struct PerformanceMetric {
    let startEvent: String
    let endEvent: String
}

class PerformanceTimer: NSObject {
    
    private static let instance = PerformanceTimer()
    
    let metrics = [
        PerformanceMetric(
            startEvent: VPerformanceEventAppLaunch,
            endEvent: VPerformanceEventLandingPagePresented,
            type: "app_start"
        )
    ]
    
    private var sharedSelf: PerformanceTimer {
        return PerformanceTimer.instance
    }
    
    private static let queue = dispatch_queue_create( "com.getvictorious.PerformanceTimer", DISPATCH_QUEUE_SERIAL )
    private var events = Set<PerformanceEvent>()
    
    func startEvent( type: String, subtype: String? ) {
        dispatch_async( PerformanceTimer.queue ) {
            let event = PerformanceEvent(type: type, subtype: subtype)
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
                let duration = dateEnded.timeIntervalSinceDate(event.date)
                print( "\n\n >>>> PerformanceTimer :: endEvent :: \(event.type) \(event.subtype) \(Int(duration * 1000.0)) <<<< \n\n" )
            }
        }
    }
}
