//
//  StreamRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct StreamRequest: Pageable {
    
    public let paginator: PaginatorType
    
    public init(paginator: PaginatorType ) {
        self.paginator = paginator
    }
    
    public init( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.paginator = StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage:itemsPerPage )
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
