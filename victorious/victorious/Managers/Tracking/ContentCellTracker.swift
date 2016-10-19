//
//  ContentCellTracker.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol ContentCellTracker {
    var sessionParameters: [AnyHashable: Any] { get }
    
    func trackView(_ trackingKey: ViewTrackingKey, showingContent content: Content, parameters: [AnyHashable: Any])
}

extension ContentCellTracker {
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }

    func trackView(_ trackingKey: ViewTrackingKey, showingContent content: Content, parameters: [AnyHashable: Any] = [:]) {
        guard
            let tracking = content.tracking,
            let trackingStrings = tracking.trackingURLs(forKey: trackingKey),
            var combinedParameters = parametersForViewTrackingKey(trackingKey, trackingURLStrings: trackingStrings)
        else {
            return
        }

        combinedParameters.unionInPlace(parameters)
        trackingManager.queueEvent(
            trackingKey.rawValue,
            parameters: combinedParameters,
            eventId: tracking.id,
            sessionParameters: sessionParameters
        )
    }

    private func parametersForViewTrackingKey(_ trackingKey: ViewTrackingKey, trackingURLStrings: [String]) -> [AnyHashable: Any]? {
        let parameters = [
            VTrackingKeyTimeStamp: Date(),
            VTrackingKeyUrls: trackingURLStrings
        ] as [String : Any]
        
        switch trackingKey {
            case .cellView, .cellClick, .viewStart: break
            default:
                assertionFailure("not implemented yet")
                return nil
        }
        
        return parameters
    }
}
