//
//  ConversationListRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

// A RequestType to grab pages of the currently logged in user's conversation
public struct ConversationListRequest: RequestType /* FIXME */{
    
    private static let basePath = NSURL(string: "/api/message/conversation_list")!
    private let paginator: StandardPaginator
    
    // Masks the Paginator initialization
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(paginator: StandardPaginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: ConversationListRequest.basePath)
        paginator.addPaginationArgumentsToRequest(urlRequest)
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Conversation], nextPage: ConversationListRequest?, previousPage: ConversationListRequest?) {
        guard let conversationArrayJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = conversationArrayJSON.flatMap{ Conversation(json: $0) }
        let nextPageRequest: ConversationListRequest? = conversationArrayJSON.count > 0 ? ConversationListRequest(paginator: paginator.nextPage) : nil
        let previousPageRequest: ConversationListRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = ConversationListRequest(paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
