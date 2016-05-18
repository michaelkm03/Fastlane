//
//  ViewedContentFeedRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ViewedContentFeedRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StreamPaginator
    public let apiPath: String
    public let sequenceID: String?
    
    public init?( apiPath: String, sequenceID: String?, paginator: StreamPaginator? = nil ) {
        if let paginator = paginator ?? StreamPaginator(apiPath: apiPath, sequenceID: sequenceID) {
            self.init( apiPath: apiPath, sequenceID: sequenceID, paginator: paginator )
        } else {
            return nil
        }
    }
    
    public init( apiPath: String, sequenceID: String?, paginator: StreamPaginator ) {
        self.paginator = paginator
        self.apiPath = apiPath
        self.sequenceID = sequenceID
    }
    
    public init(request: ViewedContentFeedRequest, paginator: StreamPaginator) {
        self.init(apiPath: request.apiPath, sequenceID: request.sequenceID, paginator: paginator)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL()
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [ViewedContent] {
        
        let viewedContents = responseJSON["payload"]["viewed_contents"]
        
        if viewedContents.array != nil {
            let viewedContentObjects = (viewedContents.array ?? []).flatMap({ ViewedContent(json: $0) })
            return viewedContentObjects
        } else {
            throw ResponseParsingError()
        }
    }
}
