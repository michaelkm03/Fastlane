//
//  CreatorListRequest.swift
//  victorious
//
//  Created by Tian Lan on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A network request to retrive the list of creators (API Owners)
/// Response of this request should be `[User]`
public struct CreatorListRequest: RequestType {
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
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [UserModel] {
        guard let json = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { User(json: $0) }
    }
}
