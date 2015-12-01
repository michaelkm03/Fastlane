//
//  PerformanceTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

// TODO: Save to file, integrate with template
let metrics = [
    PerformanceMetric(
        startEvent: VPerformanceEventAppLaunch,
        endEvent: VPerformanceEventLandingPagePresented,
        type: "app_start"
    ),
    PerformanceMetric(
        startEvent: VPerformanceEventAppLaunch,
        endEvent: VPerformanceEventRegistrationPresented,
        type: "show_registration"
    ),
    PerformanceMetric(
        startEvent: VPerformanceEventRegstrationOptionSelected,
        endEvent: VPerformanceEventSignupCompleted,
        type: "signup"
    ),
    PerformanceMetric(
        startEvent: VPerformanceEventRegstrationOptionSelected,
        endEvent: VPerformanceEventLoginCompleted,
        type: "login"
    )
]

class PerformanceTracker: NSObject {
    
    private static let instance = PerformanceTracker()
    
    private var sharedSelf: PerformanceTracker {
        return PerformanceTracker.instance
    }
    
    private var events = Set<PerformanceEvent>()
    
    func reset() {
        sharedSelf.events.removeAll()
    }
    
    func eventOccurred( eventName: String ) {
        eventOccurred( eventName, userInfo: nil )
    }
    
    func eventOccurred( eventName: String, userInfo: String? ) {
        let currentEvent = PerformanceEvent(name: eventName, userInfo:userInfo)
        
        if let metric = metrics.filter({ $0.endEvent == eventName }).first,
            let startEvent = sharedSelf.events.filter({ $0.name == metric.startEvent }).first {
                let duration = currentEvent.date.timeIntervalSinceDate( startEvent.date )
                print( "\n\t\t>>> >>> >>> Performance: \"\(metric.type)\" :: \(duration) seconds :: \(currentEvent.userInfo)\n" )
                sharedSelf.events.remove( startEvent )
        }
        sharedSelf.events.insert( currentEvent )
    }
}
