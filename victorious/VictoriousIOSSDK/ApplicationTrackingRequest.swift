//
//  ApplicationTrackingRequest.swift
//  victorious
//
//  Created by Josh Hinman on 1/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ApplicationTrackingRequest: RequestType {
    public let trackingURL: NSURL
    
    /// This number should start at 1 and increase +1 for each tracking call
    public let eventIndex: Int
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(url: trackingURL as URL)
        urlRequest.setValue(String(eventIndex), forHTTPHeaderField: "X-Client-Event-Index")
        return urlRequest
    }
    
    public init(trackingURL: NSURL, eventIndex: Int) {
        self.trackingURL = trackingURL
        self.eventIndex = eventIndex
    }
}
