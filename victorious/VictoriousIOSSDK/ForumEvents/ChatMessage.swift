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
    public let serverTime: NSDate

    public let text: String?
    public let mediaAttachment: MediaAttachment?
    public let fromUser: ChatMessageUser
    
    public init?(json: JSON, serverTime: NSDate) {
        self.serverTime = serverTime
        
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
    
    public init?(serverTime: NSDate = NSDate(), fromUser: ChatMessageUser, text: String? = nil, mediaAttachment: MediaAttachment? = nil) {
        guard text != nil || mediaAttachment != nil else {
            return nil
        }

        self.serverTime = serverTime
        self.fromUser = fromUser
        self.text = text
        self.mediaAttachment = mediaAttachment
    }
    
    // MARK: DictionaryConvertible
    
    public var rootKey: String {
        return "chat"
    }

    public var rootTypeKey: String? {
        return "type"
    }

    public var rootTypeValue: String? {
        return "CHAT"
    }

    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["type"] = "TEXT"
        dictionary["text"] = text
        dictionary["user"] = fromUser.toDictionary()
        dictionary["media"] = mediaAttachment?.toDictionary()
        return dictionary
    }
}
