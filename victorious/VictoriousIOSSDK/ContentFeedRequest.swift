//
//  ContentFeedRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentFeedRequest: RequestType {
    public let url: NSURL
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (contents: [Content], refreshStage: RefreshStage?) {
        guard let contents = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        let mainStageJSON = responseJSON["main_stage"]
        
        let parsedContents = contents.flatMap { Content(json: $0) }
        let stageMetaData = StageMetaData(title: mainStageJSON["title"].string)
        let parsedRefreshStage = RefreshStage(json: mainStageJSON, stageMetaData: stageMetaData)
        
        return (parsedContents, parsedRefreshStage)
    }
}
