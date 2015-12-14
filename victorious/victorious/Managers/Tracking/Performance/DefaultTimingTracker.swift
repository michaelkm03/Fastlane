//
//  DefaultTimingTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

private struct AppTimingEvent: Hashable {
    let type: String
    let subtype: String?
    let dateStarted = NSDate()
    
    init(type: String, subtype: String?) {
        self.type = type
        self.subtype = subtype
    }
	
	var hashValue: Int {
		return self.type.hashValue
	}
}

private func ==(lhs: AppTimingEvent, rhs: AppTimingEvent) -> Bool {
	return lhs.type == rhs.type
}

/// Object that manages performance event tracking by measuring time between start and stop calls.
class DefaultTimingTracker: NSObject, TimingTracker {
    
    static let defaultURLString = "/api/tracking/app_time?type=%%TYPE%%&subtype=%%SUBTYPE%%&time=%%DURATION%%"
    
    private(set) var urls = [String]()
    private var activeEvents = Set<AppTimingEvent>()
    private static var instance: DefaultTimingTracker?
	
	/// An object to which the actual tracking will be delegated once a performance event has been
	/// recorded and its duration calculated.  Defaults to using `VTrackingManager`.
	var tracker: VTracker? = VTrackingManager.sharedInstance()
    
    /// Singleton initializer.  An internally-defined default URL will be used to track events if one has not been
    ///  provided by calling `sharedInstance(dependencyManager:tracker:)`.  In the latter case, the value is read
    /// from the template through the provided dependency manager and used in favor of the default.
    class func sharedInstance() -> DefaultTimingTracker {
        if let instance = instance {
            return instance
        } else {
            let newInstance = DefaultTimingTracker()
            instance = newInstance
            return newInstance
        }
    }
    
    /// Singleton initializer with dependency manager to provide tracking endpoint URL value is read
    /// from the template and used in favor of the default.
    class func sharedInstance( dependencyManager dependencyManager: VDependencyManager ) -> DefaultTimingTracker {
        let instance = sharedInstance()
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
    
    func resetAllEvents() {
        self.activeEvents.removeAll()
    }
    
    func resetEvent(type type: String) {
        if let existing = self.activeEvents.lazy.filter({ $0.type == type }).first {
            self.activeEvents.remove( existing )
        }
    }
    
    func startEvent(type type: String, subtype: String? = nil) {
        self.resetEvent(type: type)
        let event = AppTimingEvent(type: type, subtype: subtype)
        self.activeEvents.insert( event )
    }
    
    func endEvent(type type: String, subtype: String? = nil) {
        if let event = self.activeEvents.lazy.filter({ $0.type == type }).first {
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
        tracker?.trackEvent(VTrackingEventApplicationPerformanceMeasured, parameters: params)
    }
}
