//
//  AppTimingTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

// TODO: Integrate with template
let appTimeURL = "http://dev.getvictorious.com/api/tracking/app_time?type=%%SUBTYPE%%&subtype=%%SUBTYPE%%&time=%%DURATION%%"


private struct AppTimingEvent: Hashable {
    let type: String
    let subtype: String?
    let dateStarted = NSDate()
    
    var hashValue: Int {
        return type.hashValue + (subtype?.hashValue ?? 0)
    }
}

private func ==(lhs: AppTimingEvent, rhs: AppTimingEvent ) -> Bool {
    return lhs.type == rhs.type && lhs.subtype == rhs.subtype
}

class AppTimingTracker: NSObject {
    
    let urls: [String]
    
    private var activeEvents = Set<AppTimingEvent>()
    private static var instance: AppTimingTracker?
    
    class func sharedInstance( dependencyManager dependencyManager: VDependencyManager ) -> AppTimingTracker? {
        return AppTimingTracker.sharedInstance( dependencyManager: dependencyManager )
    }
    
    class func sharedInstance() -> AppTimingTracker? {
        return AppTimingTracker.sharedInstance( dependencyManager: nil )
    }
    
    private class func sharedInstance( dependencyManager dependencyManager: VDependencyManager? ) -> AppTimingTracker? {
        if let instance = instance {
            return instance
        } else if let newInstance = AppTimingTracker(dependencyManager: dependencyManager){
            instance = newInstance
        }
        return instance
    }
    
    private convenience init?( dependencyManager: VDependencyManager? = nil ) {
        if let urls = dependencyManager?.trackingURLsForKey( "app_time" ) as? [String] {
            self.init(urls: urls)
        } else {
            return nil
        }
    }
    
    private init(urls: [String]) {
        self.urls = urls
    }
    
    func resetAllEvents() {
        self.activeEvents.removeAll()
    }
    
    func resetEvent(type type: String) {
        if let existing = self.activeEvents.filter({ $0.type == type }).first {
            self.activeEvents.remove( existing )
        }
    }
    
    func startEvent(type type: String, subtype: String? = nil) {
        self.resetEvent(type: type)
        let event = AppTimingEvent(type: type, subtype: subtype)
        self.activeEvents.insert( event )
    }
    
    func endEvent(type type: String, subtype: String? = nil) {
        if let event = self.activeEvents.filter({ $0.type == type }).first {
            trackEvent( event )
            self.activeEvents.remove( event )
        }
    }
    
    private func trackEvent( event: AppTimingEvent ) {
        let duration = NSDate().timeIntervalSinceDate( event.dateStarted )
        let params: [NSObject : AnyObject] = [
            VTrackingKeyUrls : [ appTimeURL ],
            VTrackingKeyDuration : duration,
            VTrackingKeyType : event.type,
            VTrackingKeySubtype : event.subtype ?? ""
        ]
        print( "\n\t\t>>> >>> >>> Performance: \"\(event.type)\" | \"\(event.subtype)\" :: \(duration) milliseconds.\n" )
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventApplicationPerformanceMeasured, parameters: params)
    }
}
