//
//  ContentFeedRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentFeedRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> ContentFeedResult {
        guard let contents = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        let parsedContents = contents.flatMap { Content(json: $0) }
        
        var parsedRefreshStage: RefreshStage? = nil
        let mainStageJSON = responseJSON["main_stage"]
        
        // A missing "main_stage" node in JSON represents no content on the stage.
        if mainStageJSON.isExists() {
            parsedRefreshStage = RefreshStage(json: mainStageJSON)
        }
        
        return ContentFeedResult(contents: parsedContents, refreshStage: parsedRefreshStage)
    }
}

public struct ContentFeedResult {
    public var contents: [Content]
    public var refreshStage: RefreshStage?
}
