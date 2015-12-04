//
//  ConversationRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

// A RequestType for fetching pages of messages for a particular conversation.
public struct ConversationRequest: RequestType /* FIXME */{
    
    /// The conversation for this request
    public let conversationID: Int64
    private static let basePath = NSURL(string: "/api/message/conversation/")!
    private static let descPathParameter = "desc"
    private let paginator: StandardPaginator
    
    // Masks the paginator
    public init(conversationID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 10) {
        self.init(conversationID: conversationID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(conversationID: Int64, paginator: StandardPaginator) {
        self.conversationID = conversationID
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let path = ConversationRequest.basePath.URLByAppendingPathComponent(String(self.conversationID)).URLByAppendingPathComponent(ConversationRequest.descPathParameter)
        let urlRequest = NSMutableURLRequest(URL:path)
        paginator.addPaginationArgumentsToRequest(urlRequest)
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Message], nextPage: ConversationRequest?, previousPage: ConversationRequest?) {
        guard let messageArrayJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = messageArrayJSON.flatMap{ Message(json: $0) }
        let nextPageRequest: ConversationRequest? = messageArrayJSON.count > 0 ? ConversationRequest(conversationID: self.conversationID, paginator: paginator.nextPage) : nil
        let previousPageRequest: ConversationRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = ConversationRequest(conversationID: self.conversationID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
    
}
