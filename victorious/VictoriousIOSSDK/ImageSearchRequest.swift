//
//  ImageSearchRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Returns a list of images based on a search term
public struct ImageSearchRequest: Pageable {
    
    // A term to use when searching for images
    public let searchTerm: String
    
    public var urlRequest: NSURLRequest
    
    private let paginator: StandardPaginator
    
    public init(searchTerm: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(searchTerm: searchTerm, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(searchTerm: String, paginator: StandardPaginator) {
        
        let url = NSURL(string: "/api/image/search")!.URLByAppendingPathComponent(searchTerm)
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(mutableURLRequest)
        urlRequest = mutableURLRequest
        
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [ImageSearchResult], nextPage: ImageSearchRequest?, previousPage: ImageSearchRequest?) {
        
        guard let imagesJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = imagesJSON.flatMap { ImageSearchResult(json: $0) }
        let nextPageRequest: ImageSearchRequest? = imagesJSON.count > 0 ? ImageSearchRequest(searchTerm: searchTerm, paginator: paginator.nextPage) : nil
        let previousPageRequest: ImageSearchRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = ImageSearchRequest(searchTerm: searchTerm, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}