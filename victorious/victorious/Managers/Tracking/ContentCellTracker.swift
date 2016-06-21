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
    
    func trackCell(cell: ContentCell, trackingKey: TrackingKey)
}

extension ContentCellTracker {
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }

    func trackCell(cell: ContentCell, trackingKey: TrackingKey) {
        guard
            let content = cell.content,
            let eventId = content.id,
            let parameters = parametersForTrackingKey(trackingKey, content: content)
        else {
            return
        }
        
        trackingManager.queueEvent(
            trackingKey.rawValue,
            parameters: parameters,
            eventId: eventId,
            sessionParameters: sessionParameters
        )
    }
    
    private func parametersForTrackingKey(trackingKey: TrackingKey, content: ContentModel) -> [NSObject : AnyObject]? {
        guard let trackingURLstrings = content.tracking?.trackingURLsForKey(trackingKey) else {
            return nil
        }
        
        let parameters = [
            VTrackingKeyTimeStamp : NSDate(),
            VTrackingKeyUrls : trackingURLstrings
        ]
        
        switch trackingKey {
            case .cellView: ()
            default:
                assertionFailure("not implemented yet")
                return nil
        }
        
        return parameters
    }
}
