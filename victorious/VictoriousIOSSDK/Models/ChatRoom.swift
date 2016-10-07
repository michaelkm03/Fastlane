//
//  ChatRoom.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct ChatRoom {
    public typealias ID = String
    public var id: ID
    public var name: String

    public init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
}

extension ChatRoom {
    public init?(json: JSON) {
        guard
            let id = json["id"].string,
            let name = json["name"].string
        else {
            return nil
        }
        
        self.id = id
        self.name = name
    }
}
