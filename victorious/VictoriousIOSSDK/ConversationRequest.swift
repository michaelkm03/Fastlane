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
public struct ConversationRequest: PaginatorPageable, ResultBasedPageable {

    private static let basePath = NSURL(string: "/api/message/conversation/")!
    
    /// The conversation for this request
    public let conversationID: Int
    private static let descPathParameter = "desc"
    
    public let paginator: StandardPaginator
    
    public init(request: ConversationRequest, paginator: StandardPaginator) {
        self.init( conversationID: request.conversationID, paginator: request.paginator)
    }
    
    public init(conversationID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.conversationID = conversationID
        self.paginator = paginator
    }

    public var urlRequest: NSURLRequest {
        let path = ConversationRequest.basePath.URLByAppendingPathComponent(String(self.conversationID)).URLByAppendingPathComponent(ConversationRequest.descPathParameter)
        let urlRequest = NSMutableURLRequest(URL:path)
        paginator.addPaginationArgumentsToRequest(urlRequest)
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Message] {

        guard let messageArrayJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return messageArrayJSON.flatMap{ Message(json: $0) }
    }
}
