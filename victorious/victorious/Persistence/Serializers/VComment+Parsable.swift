//
//  VComment+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VComment : PersistenceParsable {
    
    func populate( fromSourceModel comment: Comment ) {
        remoteId                = NSNumber(longLong: comment.commentID)
        shouldAutoplay          = comment.shouldAutoplay
        text                    = comment.text
        mediaType               = comment.mediaType?.rawValue
        mediaUrl                = comment.mediaURL?.absoluteString
        thumbnailUrl            = comment.thumbnailURL?.absoluteString
        flags                   = comment.flags
        dislikes                = NSNumber(longLong: comment.dislikes)
        flags                   = comment.flags
        likes                   = NSNumber(longLong: comment.likes)
        mediaType               = comment.mediaType?.rawValue
        mediaUrl                = comment.mediaURL?.absoluteString
        parentId                = NSNumber(longLong: comment.parentID)
        postedAt                = comment.postedAt
        shouldAutoplay          = comment.shouldAutoplay
        text                    = comment.text
        sequenceId              = String(comment.sequenceID)
        userId                  = NSNumber(longLong:comment.userID)        
        
        // Set the sequence and inStreamSequence based on the comment's sequenceID if a Sequence object isn't set
        if sequence == nil {
            sequence = persistentStoreContext.findOrCreateObject([ "remoteId" : String(comment.sequenceID) ]) as VSequence
            inStreamSequence = sequence
        }
        
        // Set the user based on the comment's user if a User object isn't set
        if user == nil {
            user = persistentStoreContext.findOrCreateObject([ "remoteId" : NSNumber(longLong:comment.user.userID) ]) as VUser
            user.populate( fromSourceModel: comment.user )
        }
        
    }
}
