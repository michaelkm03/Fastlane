//
//  TutorialContentsRequest.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Netowrk request to fetch an array of content which will be displayed as tutorial messages
public struct TutorialContentsRequest: RequestType {
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
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [Content] {
        guard let json = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { Content(json: $0) }
    }
}
