//
//  UserBlockRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserBlockRequest: RequestType {
    private let url: URL
    private let userID: User.ID
    
    public init?(apiPath: APIPath, userID: User.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = String(userID)
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.userID = userID
    }
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["user_id": String(userID)])
        return request
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws {
        // Protocol conformance
    }
}
