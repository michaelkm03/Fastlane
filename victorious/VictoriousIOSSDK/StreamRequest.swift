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
    
    let pageNumber: Int
    let itemsPerPage: Int
    let apiPath: String
    let sequenceID: String?
    
    public let urlRequest: NSURLRequest
    
    public init?( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        self.sequenceID = sequenceID
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
        
        guard let streamURL = StreamURLMacros.urlWithMacrosReplaced( apiPath,
            sequenceID: sequenceID,
            pageNumber: pageNumber,
            itemsPerPage: itemsPerPage) else {
                return nil
        }
        self.urlRequest = NSMutableURLRequest(URL: streamURL)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: Stream, nextPage: StreamRequest?, previousPage: StreamRequest?) {
        
        let payload = responseJSON["payload"]
        guard let stream = Stream(json: payload) else {
            throw ResponseParsingError()
        }
        
        let nextPageRequest = StreamRequest( apiPath: apiPath,
            sequenceID: sequenceID,
            pageNumber: pageNumber + 1,
            itemsPerPage: itemsPerPage )
        
        let prevPageRequest = StreamRequest( apiPath: apiPath,
            sequenceID: sequenceID,
            pageNumber: pageNumber - 1,
            itemsPerPage: itemsPerPage )
        
        return (
            results: stream,
            nextPage: stream.items.count == 0 ? nil : nextPageRequest,
            previousPage: pageNumber == 1 ? nil : prevPageRequest
        )
    }
}
