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
    func trackButtonEvent(event: ButtonTrackingEvent, forTrackingKey trackingKey: String = VDependencyManager.defaultTrackingKey) {
        guard let apiPaths = trackingAPIPaths(forEventKey: event.rawValue, trackingKey: trackingKey) where !apiPaths.isEmpty else {
            return
        }
        
        VTrackingManager.sharedInstance().trackEvent(event.rawValue, parameters: [
            VTrackingKeyUrls: apiPaths.map { $0.templatePath }
        ])
    }
}
