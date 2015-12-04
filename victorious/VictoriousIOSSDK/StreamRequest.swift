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
    
    public init( apiPath: String, sequenceID: String? = nil) {
        self.paginator = StreamPaginator(apiPath: apiPath, sequenceID: sequenceID)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL()
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [StreamItemType] {
        
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
        
        return stream.items
    }
}

public struct StreamPaginator: PaginatorType {
    
    public enum Macro: String {
        case PageNumber     = "%%PAGE_NUM%%"
        case ItemsPerPage   = "%%ITEMS_PER_PAGE%%"
        case SequenceID     = "%%SEQUENCE_ID%%"
        
        static var all: [Macro] {
            return [ .PageNumber, .ItemsPerPage, .SequenceID ]
        }
    }
    
    public let apiPath: String
    public let sequenceID: String?
    
    public init(apiPath: String, pageNumber: Int = 1, itemsPerPage: Int = 15, sequenceID: String? = nil) {
        self.apiPath = apiPath
        self.sequenceID = sequenceID
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - PaginatorType
    
    public let pageNumber: Int
    public let itemsPerPage: Int
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = urlWithMacrosReplaced( apiPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage )
    }
    
    public func getPreviousPage() -> PaginatorType? {
        if pageNumber > 1 {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func getNextPage( resultCount: Int ) -> PaginatorType? {
        if resultCount >= itemsPerPage {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    private func urlWithMacrosReplaced( apiPath: String, sequenceID: String?, pageNumber: Int = 1, itemsPerPage: Int = 15) -> NSURL? {
        var apiPathWithMacrosReplaced = apiPath
        for macro in Macro.all where apiPath.containsString(macro.rawValue) {
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
