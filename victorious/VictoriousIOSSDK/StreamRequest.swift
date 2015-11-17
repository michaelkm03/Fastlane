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
    
    public let apiPath: String
    public let sequenceID: String?
    
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

private enum StreamURLMacros: String {
    
    case PageNumber     = "%%PAGE_NUM%%"
    case ItemsPerPage   = "%%ITEMS_PER_PAGE%%"
    case SequenceID     = "%%SEQUENCE_ID%%"
    
    static var all: [StreamURLMacros] {
        return [ .PageNumber, .ItemsPerPage, .SequenceID ]
    }
    
    static func urlWithMacrosReplaced( apiPath: String, sequenceID: String?, pageNumber: Int = 1, itemsPerPage: Int = 15) -> NSURL? {
        var apiPathWithMacrosReplaced = apiPath
        for macro in StreamURLMacros.all where apiPath.containsString(macro.rawValue) {
            switch macro {
            case .PageNumber:
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: String(pageNumber))
            case .ItemsPerPage:
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: String(itemsPerPage))
            case .SequenceID:
                guard let sequenceID = sequenceID else {
                    return nil
                }
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: sequenceID)
            }
        }
        return NSURL(string: apiPathWithMacrosReplaced)
    }
}
