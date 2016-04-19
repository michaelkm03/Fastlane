//
//  ChatMessageInbound.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  Incoming chat messages over the WebSocket, will be broadcasted over the Forum Event Chain.
 */
public struct ChatMessageInbound: ForumEvent {
    // MARK: ForumEvent
    public let timestamp: NSDate

    public let text: String?
    public let contentURL: NSURL?
    public let giphyUrl: NSURL?
    public let fromUser: ChatMessageUser
    
    public init?(json: JSON, timestamp: NSDate) {
        self.timestamp = timestamp
        
        text = json["text"].string
        contentURL = json["content_url"].URL
        giphyUrl = json["giphy_url"].URL
        
        guard let user = ChatMessageUser(json: json["from_user"]) else {
            assertionFailure("No able to parse user from incoming chat message. JSON -> \(json)")
            return nil
        }
        
        fromUser = user
        
        // Either one of these types are required to be counted as a chat message.
        guard text != nil || contentURL != nil || giphyUrl != nil else {
            assertionFailure("Chat message invalid, unable to parse out any content. JSON -> \(json)")
            return nil
        }
    }
}
