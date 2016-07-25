//
//  ChatUserCount.swift
//  victorious
//
//  Created by Sebastian Nystorm on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A message indicating how many users are in the chat at the current time it was sent.
public struct ChatUserCount {

    public let serverTime: Timestamp

    /// The current count of users in the chat.
    public let userCount: Int

    public init?(json: JSON, serverTime: Timestamp) {
        self.serverTime = serverTime

        guard let userCount = json["chat_users"].int else {
            return nil
        }

        self.userCount = userCount
    }

    public init(serverTime: Timestamp, count: Int) {
        self.serverTime = serverTime
        self.userCount = count
    }
}
