//
//  ApplicationTrackingRequest.swift
//  victorious
//
//  Created by Josh Hinman on 1/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ApplicationTrackingRequest: RequestType {
    public let trackingURL: URL
    
    /// This number should start at 1 and increase +1 for each tracking call
    public let eventIndex: Int
    
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: trackingURL)
        urlRequest.setValue(String(eventIndex), forHTTPHeaderField: "X-Client-Event-Index")
        return urlRequest
    }
    
    public init(trackingURL: URL, eventIndex: Int) {
        self.trackingURL = trackingURL
        self.eventIndex = eventIndex
    }
}
