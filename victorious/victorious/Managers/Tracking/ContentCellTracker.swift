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
    
    func trackCell(cell: ContentCell, trackingKey: CellTrackingKey)
    func trackView(trackingKey: ViewTrackingKey)
}

extension ContentCellTracker {
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }

    func trackCell(cell: ContentCell, trackingKey: CellTrackingKey) {
        guard
            let content = cell.content,
            let eventId = content.id,
            let trackingStrings = content.tracking?.trackingURLsForKey(trackingKey),
            let parameters = parametersForCellTrackingKey(trackingKey, trackingURLStrings: trackingStrings)
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
    
    private func parametersForCellTrackingKey(trackingKey: CellTrackingKey, trackingURLStrings: [String]) -> [NSObject : AnyObject]? {
        
        let parameters = [
            VTrackingKeyTimeStamp : NSDate(),
            VTrackingKeyUrls : trackingURLStrings
        ]
        
        switch trackingKey {
            case .cellView: ()
            default:
                assertionFailure("not implemented yet")
                return nil
        }
        
        return parameters
    }
    
    func trackView(trackingKey: ViewTrackingKey) {
        assertionFailure("not implemented yet")
    }
}
