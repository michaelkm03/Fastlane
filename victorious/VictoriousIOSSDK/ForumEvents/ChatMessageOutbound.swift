//
//  ChatMessageOutbound.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  Outgoing chat messages that will travel to the server over the WebSocket.
 */
public struct ChatMessageOutbound: ForumEvent, JSONConvertable {
    // MARK: ForumEvent
    public let timestamp: NSDate
    
    public let text: String?
    public let contentURL: NSURL?
    public let giphyID: String?

    public init?(timestamp: NSDate = NSDate(), text: String? = nil, contentUrl: NSURL? = nil, giphyID: String? = nil) {
        
        guard((text != nil) || (contentUrl != nil) || (giphyID != nil)) else {
            assertionFailure("A outbound chat message needs to have text, contentUrl or giphyID set in order to work.")
            return nil
        }
     
        self.timestamp = timestamp
        self.text = text
        self.contentURL = contentUrl
        self.giphyID = giphyID
    }

    // MARK: JSONConvertible
    
    public func toJSON() -> JSON {
        var messageAsDictionary = [String: AnyObject]()
        
        if let text = text {
            messageAsDictionary["text"] = text
        }
        
        if let contentURL = contentURL {
            messageAsDictionary["content_url"] = contentURL
        }
        
        if let giphyID = giphyID {
            messageAsDictionary["giphy_id"] = giphyID
        }
        
        return JSON(["chat": messageAsDictionary])
    }
}
