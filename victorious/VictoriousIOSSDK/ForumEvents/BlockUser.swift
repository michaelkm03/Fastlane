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
public struct BlockUser: DictionaryConvertible {
    
    public let userID: String

    // MARK: DictionaryConvertible
    
    public var rootKey: String {
        return "mute"
    }

    public var rootTypeKey: String? {
        return "type"
    }

    public var rootTypeValue: String? {
        return "MUTE"
    }
    
    public func toDictionary() -> [String: AnyObject] {
        var muteAsDictionary = [String: AnyObject]()
        muteAsDictionary["user_id"] = userID as AnyObject?
        return muteAsDictionary
    }
}
