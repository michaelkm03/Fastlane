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
    private(set) var apiPaths = [APIPath]()
    private var activeEvents = Set<AppTimingEvent>()
    private static let instance = DefaultTimingTracker()
    
    /// Setter allowing calling code to provide an object to which the actual tracking
    /// request execution will be delegated once a performance event has been
    /// recorded and its duration calculated.  Defaults to using `VTrackingManager`.
    var tracker: VEventTracker? = VTrackingManager.sharedInstance()
    
    /// Singleton initializer.  An internally-defined default URL will be used to track events if one has not been
    /// provided by calling `sharedInstance(dependencyManager:tracker:)`.  In the latter case, the value is read
    /// from the template through the provided dependency manager and used in favor of the default.
    class func sharedInstance() -> DefaultTimingTracker {
        return instance
    }
    
    /// Provides a dependency manager from which the shared instance will parse out its dependencies.
    func setDependencyManager(dependencyManager: VDependencyManager) {
        apiPaths = dependencyManager.trackingAPIPaths(forEventKey: "app_time") ?? []
    }
    
    func resetAllEvents() {
        self.activeEvents.removeAll()
    }
    
    func resetAllEvents(type type: String) {
        let existing = self.activeEvents.filter({ $0.type == type })
        for event in existing {
            self.activeEvents.remove( event )
        }
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
    
    private func trackEvent(event: AppTimingEvent) {
        let durationMs = Int(NSDate().timeIntervalSinceDate(event.dateStarted) * 1000.0)
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: apiPaths.map { $0.templatePath },
            VTrackingKeyDuration: durationMs,
            VTrackingKeyType: event.type,
            VTrackingKeySubtype: event.subtype ?? ""
        ]
        tracker?.trackEvent(VTrackingEventApplicationPerformanceMeasured, parameters: params)
    }
}
