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
}

extension VDependencyManager {
    func trackButtonEvent(event: ButtonTrackingEvent) {
        guard let urls = trackingURLsForKey(event.rawValue) where !urls.isEmpty else {
            return
        }
        VTrackingManager.sharedInstance().trackEvent(event.rawValue, parameters: [ VTrackingKeyUrls : urls ])
    }
}
