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
    
    public struct Result {
        public let stream: Stream
        let nextPage: StreamRequest?
        let previousPage: StreamRequest?
        
        public init( stream: Stream, nextPage: StreamRequest? = nil, previousPage: StreamRequest? = nil ) {
            self.stream = stream
            self.nextPage = nextPage
            self.previousPage = previousPage
        }
    }
    
    public let apiPath: String
    
    public init( apiPath: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public init?( apiPath: String, previousPageWithPaginator paginator: StandardPaginator) {
        let pageNumber = paginator.pageNumber - 1
        if pageNumber <= 0 {
            return nil
            
        }
        self.init( apiPath: apiPath, pageNumber: pageNumber, itemsPerPage: paginator.itemsPerPage)
    }
    
    private let paginator: StandardPaginator
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: self.apiPath)!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: Stream, nextPage: StreamRequest?, previousPage: StreamRequest?) {
        
        let payload = responseJSON["payload"]
        guard let stream = Stream(json: payload) else {
            throw ResponseParsingError()
        }
        
        return (
            results: stream,
            nextPage: stream.items.count == 0 ? nil : StreamRequest( apiPath: apiPath, pageNumber: paginator.pageNumber + 1),
            previousPage: StreamRequest( apiPath: apiPath, previousPageWithPaginator: paginator )
        )
    }
}
