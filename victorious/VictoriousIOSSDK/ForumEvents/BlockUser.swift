//
//  Mute.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The block command can be sent from the client to the server over the WebSocket and basically
/// blocks any messages from the specified user from reaching this client again.
public struct BlockUser: ForumEvent, DictionaryConvertible {
    
    // MARK: ForumEvent
    
    public let serverTime: NSDate
    public let userID: String

    // MARK: DictionaryConvertible
    
    public var defaultKey: String {
        return "mute"
    }
    
    public func toDictionary() -> [String: AnyObject] {
        var muteAsDictionary = [String: AnyObject]()
        muteAsDictionary["user_id"] = userID
        return muteAsDictionary
    }
}
