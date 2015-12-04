//
//  FollowingHashtagsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of hashtags which the current user is following
public struct FollowingHashtagsRequest: RequestType /* FIXME */{
    
    private let paginator: StandardPaginator
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(paginator: StandardPaginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/subscribed_to_list")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Hashtag], nextPage: FollowingHashtagsRequest?, previousPage: FollowingHashtagsRequest?) {
        
        let results = try HashtagResponseParser().parseResponse(responseJSON)
        
        let nextPageRequest: FollowingHashtagsRequest? = results.count > 0 ? FollowingHashtagsRequest(paginator: paginator.nextPage) : nil
        let previousPageRequest: FollowingHashtagsRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = FollowingHashtagsRequest(paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
