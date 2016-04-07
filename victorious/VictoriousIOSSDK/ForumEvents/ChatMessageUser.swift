//
//  ChatMessageUser.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  The user referenced in chat messages.
 */
public struct ChatMessageUser {
    public let id: String?
    public let name: String
    public let profileUrl: NSURL?
    
    init?(json: JSON) {
        guard let name = json["name"].string else {
                assertionFailure("Failed to create ChatMessage from json -> \(json)")
                return nil
        }
        self.name = name
        self.id = json["id"].string
        self.profileUrl = json["profile_url"].URL
    }
}
