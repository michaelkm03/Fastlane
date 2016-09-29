//
//  UserInfoRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UserInfoRequest: RequestType {
    private let url: URL
    
    public init?(apiPath: APIPath, userID: User.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = String(userID)
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> User {
        guard let user = User(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return user
    }
}
