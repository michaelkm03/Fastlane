//
//  ContentCellTracker.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ContentCellTracker {
    var sessionParameters: [NSObject : AnyObject] { get }
    
    func trackView(trackingKey: ViewTrackingKey, showingContent content: ContentModel)
}

extension ContentCellTracker {
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }
    
    func trackView(trackingKey: ViewTrackingKey, showingContent content: ContentModel) {
        guard
            let tracking = content.tracking,
            let trackingStrings = tracking.trackingURLsForKey(trackingKey),
            let parameters = parametersForViewTrackingKey(trackingKey, trackingURLStrings: trackingStrings)
        else {
            return
        }
        
        trackingManager.queueEvent(
            trackingKey.rawValue,
            parameters: parameters,
            eventId: tracking.id,
            sessionParameters: sessionParameters
        )
    }
    
    private func parametersForViewTrackingKey(trackingKey: ViewTrackingKey, trackingURLStrings: [String]) -> [NSObject : AnyObject]? {
        let parameters = [
            VTrackingKeyTimeStamp: NSDate(),
            VTrackingKeyUrls: trackingURLStrings
        ]
        
        switch trackingKey {
            case .cellView, .cellClick, .viewStart: break
            default:
                assertionFailure("not implemented yet")
                return nil
        }
        
        return parameters
    }
}
