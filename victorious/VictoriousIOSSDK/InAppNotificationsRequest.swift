//
//  InAppNotificationsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Retrieves a list of notifications for the logged in user
public struct InAppNotificationsRequest: RequestType {
    public let urlRequest: URLRequest

    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.urlRequest = URLRequest(url: url)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [InAppNotification] {
        guard let notificationsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return notificationsJSON.flatMap { InAppNotification(json: $0) }
    }
}
