//
//  ChatMessage.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreGraphics

public struct ChatMessage: ForumEvent, DictionaryConvertible {
    
    // MARK: ForumEvent
    public let timestamp: NSDate

    public let text: String?
    public let mediaAttachment: MediaAttachment?
    public let fromUser: ChatMessageUser
    
    public init?(json: JSON, timestamp: NSDate) {
        self.timestamp = timestamp
        
        text = json["text"].string
        mediaAttachment = MediaAttachment(fromForumJSON: json["media"])
        
        guard let user = ChatMessageUser(json: json["user"]) else {
            return nil
        }
        
        fromUser = user
        
        // Either one of these types are required to be counted as a chat message.
        guard text != nil || mediaAttachment != nil else {
            return nil
        }
    }
    
    public init?(timestamp: NSDate = NSDate(), fromUser: ChatMessageUser, text: String? = nil, mediaAttachment: MediaAttachment? = nil) {
        guard text != nil || mediaAttachment != nil else {
            return nil
        }
        
        self.timestamp = timestamp
        self.fromUser = fromUser
        self.text = text
        self.mediaAttachment = mediaAttachment
    }
    
    // MARK: DictionaryConvertible
    
    public var defaultKey: String {
        return "chat"
    }
    
    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["text"] = text
        dictionary["user"] = fromUser.toDictionary()
        dictionary["media"] = mediaAttachment?.toDictionary()
        return dictionary
    }
}
