//
//  Mute.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  The block command can be sent from the client to the server over the WebSocket and basically
 *  blocks any messages from the specified user from reaching this client again.
 */
public struct BlockUser: ForumEvent, JSONConvertable {
    // MARK: ForumEvent
    public let timestamp: NSDate
    public let userID: String
    
    // MARK: JSONConvertible
    public func toJSON() -> JSON {
        var muteAsDictionary = [String: AnyObject]()
        muteAsDictionary["user_id"] = userID
        return JSON(["mute": muteAsDictionary])
    }
}
