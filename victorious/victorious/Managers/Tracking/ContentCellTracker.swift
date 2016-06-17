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
    
    func trackCell(cell: ContentCell, trackingKey: ViewTrackingKey)
}

extension ContentCellTracker {
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }
    
    func trackCell(cell: ContentCell, trackingKey: ViewTrackingKey) {
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
    
    private func parametersForTrackingKey(trackingKey: ViewTrackingKey, content: ContentModel) -> [NSObject : AnyObject]? {
        guard let trackingURLstrings = content.tracking?.trackingMap?[trackingKey] else {
            return nil
        }
        
        switch trackingKey {
            case .cellView:
                //TODO: Get details, fill this in
                return [
                    VTrackingKeyUrls : trackingURLstrings
                ]
        }
    }
}
