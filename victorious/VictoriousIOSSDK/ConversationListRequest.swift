//
//  ConversationListRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

// A RequestType to grab pages of the currently logged in user's conversation
public struct ConversationListRequest: PaginatorPageable, ResultBasedPageable {
    
    private static let basePath = NSURL(string: "/api/message/conversation_list")!
    
    public let paginator: StandardPaginator
    
    public init( paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
    }
    
    public init( request: ConversationListRequest, paginator: StandardPaginator ) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: ConversationListRequest.basePath)
        paginator.addPaginationArgumentsToRequest(urlRequest)
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Conversation] {
        
        guard let conversationArrayJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return conversationArrayJSON.flatMap{ Conversation(json: $0) }
    }
}
