//
//  StreamRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct StreamRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StreamPaginator
    public let apiPath: String
    public let sequenceID: Int64?
    
    public init?( apiPath: String, sequenceID: Int64?, paginator: StreamPaginator? = nil ) {
        if let paginator = paginator ?? StreamPaginator(apiPath: apiPath, sequenceID: sequenceID) {
            self.init( apiPath: apiPath, sequenceID: sequenceID, paginator: paginator )
        } else {
            return nil
        }
    }
    
    public init( apiPath: String, sequenceID: Int64?, paginator: StreamPaginator ) {
        self.paginator = paginator
        self.apiPath = apiPath
        self.sequenceID = sequenceID
    }
    
    public init(request: StreamRequest, paginator: StreamPaginator) {
        self.init(apiPath: request.apiPath, sequenceID: request.sequenceID, paginator: paginator)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL()
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Stream {
        
        let stream: Stream
        if responseJSON["payload"].array != nil,
            let streamFromItems = Stream(json: JSON([ "id" : "anonymous:stream", "items" : responseJSON["payload"] ])) {
                stream = streamFromItems
        }
        else if let streamFromObject = Stream(json: responseJSON["payload"]) {
            stream = streamFromObject
        }
        else {
            throw ResponseParsingError()
        }
        
        return stream
    }
}
