//
//  ChatRoom.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct ChatRoom {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

extension ChatRoom {
    public init?(json: JSON) {
        guard let name = json["roomname"].string else {
            return nil
        }
        self.name = name
    }
}
