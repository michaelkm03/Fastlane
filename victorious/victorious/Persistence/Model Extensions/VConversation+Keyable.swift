//
//  VConversation+Keys.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VConversation: Keyable {
    
    enum Keys: String {
        case isRead
        case lastMessageText
        case postedAt
        case remoteId
        case lastMessageContentType
        case messages
        case user
        case displayOrder
        case markForDeletion
    }
}
