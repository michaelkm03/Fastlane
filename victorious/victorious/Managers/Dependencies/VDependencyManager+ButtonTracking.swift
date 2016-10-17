//
//  VDependencyManager+ButtonTracking.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum ButtonTrackingEvent: String {
    case tap = "button_tap"
    case cancel = "button_tap_cancel"
}

extension VDependencyManager {
    /// Track a button event
    /// - parameter event: Event to track
    /// - parameter for: Template key for tracking payload
    /// - parameter with: An array of macro replacementes for tracking URL macro substitutions
    /// - parameter eventTracker: Tracker used to send events
    func trackButtonEvent(_ event: ButtonTrackingEvent, for trackingKey: String = VDependencyManager.defaultTrackingKey, with macroReplacements: [String:String]? = nil, eventTracker: VEventTracker = VTrackingManager.sharedInstance()) {
        guard var apiPaths = trackingAPIPaths(forEventKey: event.rawValue, trackingKey: trackingKey) , !apiPaths.isEmpty else {
            return
        }

        if let macroReplacements = macroReplacements {
            for index in apiPaths.indices {
                macroReplacements.forEach { macro, value in
                    apiPaths[index].macroReplacements[macro] = value
                }
            }
        }

        eventTracker.trackEvent(event.rawValue, parameters: [
            VTrackingKeyUrls: apiPaths.flatMap { $0.url?.absoluteString }
        ])
    }
}
