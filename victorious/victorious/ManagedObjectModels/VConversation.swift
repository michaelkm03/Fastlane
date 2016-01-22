//
//  VConversation.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VConversation {
    
    enum Keys: String {
        case isRead
        case lastMessageText
        case postedAt
        case remoteId
        case lastMessageContentType
        case messages
        case user
        case displayOrder
        case isFlaggedForDeletion
    }
}

extension VConversation: FlaggableForDeletion {

    static var hasPostedAtPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil", VConversation.Keys.postedAt.rawValue)
    }
    
    //MARK: - FlaggableForDeletion
    
    static var flaggedForDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", VConversation.Keys.isFlaggedForDeletion.rawValue)
    }
    
    static var notFlaggedForDeletionPredicate: NSPredicate{
        return NSPredicate(format: "%K == NO", VConversation.Keys.isFlaggedForDeletion.rawValue)
    }
    
}

protocol FlaggableForDeletion {
    static var flaggedForDeletionPredicate: NSPredicate{get}
    static var notFlaggedForDeletionPredicate: NSPredicate{get}
}
