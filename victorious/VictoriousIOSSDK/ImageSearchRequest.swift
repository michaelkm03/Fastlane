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
public struct ImageSearchRequest: PaginatorPageable, ResultBasedPageable {
	
	public let urlRequest: NSURLRequest
	public let searchTerm: String
	
	public let paginator: StandardPaginator
	
    public init( request: ImageSearchRequest, paginator: StandardPaginator ) {
        self.init( searchTerm: request.searchTerm, paginator: paginator)
    }
	
	public init(searchTerm: String, paginator: StandardPaginator = StandardPaginator() ) {
        let url = NSURL(string: "/api/image/search")!.URLByAppendingPathComponent(searchTerm)
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(mutableURLRequest)
        urlRequest = mutableURLRequest
        
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [ImageSearchResult] {

        guard let imagesJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return imagesJSON.flatMap { ImageSearchResult(json: $0) }
    }
}
