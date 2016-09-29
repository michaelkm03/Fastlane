//
//  UnreadNotificationsCountRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UnreadNotificationsCountRequest: RequestType {
    private let url: URL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> Int {
        guard let count = responseJSON["payload"]["unread_count"].int else {
            throw ResponseParsingError()
        }
        
        return count
    }
}
