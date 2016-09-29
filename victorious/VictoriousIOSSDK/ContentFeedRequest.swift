//
//  ContentFeedRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentFeedRequest: RequestType {
    private let url: URL
    private let payloadType: ContentFeedPayloadType
    
    public init?(apiPath: APIPath, payloadType: ContentFeedPayloadType) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.payloadType = payloadType
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> ContentFeedResult {
        let contentsJSON: [JSON]?
        let contentParser: (JSON) -> Content?
        
        switch payloadType {
            case .regular:
                contentsJSON = responseJSON["payload"]["viewed_contents"].array
                contentParser = { Content(json: $0) }
            case .lightweight:
                contentsJSON = responseJSON["payload"]["reference_list"].array
                contentParser = { Content(lightweightJSON: $0) }
        }
        
        guard let contents = contentsJSON else {
            throw ResponseParsingError()
        }
        
        let parsedContents = contents.flatMap { contentParser($0) }
        let parsedRefreshStage = RefreshStage(json: responseJSON["main_stage"])
        
        return ContentFeedResult(contents: parsedContents, refreshStage: parsedRefreshStage)
    }
}

public struct ContentFeedResult {
    public var contents: [Content]
    public var refreshStage: RefreshStage?
}

public enum ContentFeedPayloadType {
    /// Each content in the payload contains all the information about the content and its author
    case regular
    /// Each content in the payload only contains the basic information to be displayed in a grid stream
    case lightweight
}
