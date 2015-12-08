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
public struct FollowingHashtagsRequest: Pageable {
    
    public let paginator: Paginator
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public init(request: FollowingHashtagsRequest, paginator: Paginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/subscribed_to_list")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return hashtagJSON.flatMap { Hashtag(json: $0) }
    }
}
