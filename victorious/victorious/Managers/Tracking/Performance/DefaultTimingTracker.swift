//
//  DefaultTimingTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

private class AppTimingEvent: NSObject {
    let type: String
    let subtype: String?
    let dateStarted = NSDate()
    
    init(type: String, subtype: String?) {
        self.type = type
        self.subtype = subtype
    }
}

/// Object that manages performance event tracking by measuring time between start and stop calls.
class DefaultTimingTracker: NSObject, TimingTracker {
    
    static let defaultURLString = "/api/tracking/app_time?type=%%TYPE%%&subtype=%%SUBTYPE%%&time=%%DURATION%%"
    
    private(set) var urls = [String]()
    private var activeEvents = Set<AppTimingEvent>()
    private static var instance: DefaultTimingTracker?
    private let tracker: VTracker
    
    /// Singleton initializer with `tracker` dependency.  An internally-defined default URL
    /// will be used to track events using the provided `tracker` if one has not been provided by
    /// calling `sharedInstance(dependencyManager:tracker:)`.  In the latter case, the value is read
    /// from the template through the provided dependency manager and used in favor of the default.
    class func sharedInstance( tracker tracker: VTracker = VTrackingManager.sharedInstance() ) -> DefaultTimingTracker {
        if let instance = instance {
            return instance
        } else {
            let newInstance = DefaultTimingTracker(tracker: tracker)
            instance = newInstance
            return newInstance
        }
    }
    
    
    /// Singleton initializer with `tracker` dependency.  A tracking endpoint URL value is read
    /// from the template through the provided dependency manager and used in favor of the default.
    class func sharedInstance( dependencyManager dependencyManager: VDependencyManager, tracker: VTracker = VTrackingManager.sharedInstance() ) -> DefaultTimingTracker {
        let instance = sharedInstance(tracker: tracker)
        if let urls = dependencyManager.trackingURLsForKey( "app_time" ) as? [String] {
            instance.urls = urls
        } else {
            if let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment {
                let fullURL = (currentEnvironment.baseURL.absoluteString as NSString).stringByAppendingPathComponent(self.defaultURLString)
                instance.urls = [ fullURL ]
            }
        }
        return instance
    }
    
    private init(tracker: VTracker) {
        self.tracker = tracker
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
        let durationMs = Int64(NSDate().timeIntervalSinceDate( event.dateStarted ) * 1000.0)
        let params: [NSObject : AnyObject] = [
            VTrackingKeyUrls : self.urls,
            VTrackingKeyDuration : NSNumber(longLong: durationMs),
            VTrackingKeyType : event.type,
            VTrackingKeySubtype : event.subtype ?? ""
        ]
        tracker.trackEvent(VTrackingEventApplicationPerformanceMeasured, parameters: params)
    }
}
