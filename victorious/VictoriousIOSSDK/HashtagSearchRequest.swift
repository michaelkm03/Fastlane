//
//  HashtagSearchRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct HashtagSearchRequest: PaginatorPageable, ResultBasedPageable {
    
    public let searchTerm: String
    
    let context: SearchContext?
    
    public let paginator: StandardPaginator
    
    let url: NSURL
    
    public init(request: HashtagSearchRequest, paginator: StandardPaginator ) {
        self.searchTerm = request.searchTerm
        self.url = request.url
        self.context = request.context
        self.paginator = paginator
    }
    
    // param: - searchTerm must be a urlPathPart percent encoded string
    public init?(searchTerm: String, context: SearchContext? = nil, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 50)) {
        
        let charSet = NSCharacterSet.vsdk_pathPartAllowedCharacterSet
        guard let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(charSet),
            let url = NSURL(string: "/api/hashtag/search/\(escapedSearchTerm)") else {
                return nil
        }
        
        self.url = url
        self.context = context
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        if let context = context {
            let contextualURL = request.URL!.URLByAppendingPathComponent(context.rawValue)
            return NSURLRequest(URL: contextualURL)
        } else {
            return request.copy() as! NSURLRequest
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        
        if let hashtagStrings = responseJSON["payload"].rawValue as? [String] {
            return hashtagStrings.flatMap { Hashtag(tag: $0) }
        
        } else if let hashtags = responseJSON["payload"].array {
            return hashtags.flatMap { Hashtag(json: $0) }
        
        } else {
            throw ResponseParsingError()
        }
    }
}
