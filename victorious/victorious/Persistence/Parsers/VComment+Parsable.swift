//
//  VComment+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VComment: PersistenceParsable {
    
    func populate( fromSourceModel comment: Comment ) {
        remoteId                = comment.commentID
        sequenceId              = String(comment.sequenceID)
        postedAt                = comment.postedAt
        
        parentId                = comment.parentID ?? parentId
        text                    = comment.text ?? text
        flags                   = comment.flags ?? flags
        likes                   = comment.likes ?? likes
        text                    = comment.text ?? text
        userId                  = comment.userID ?? parentId
        
        if let mediaAttachment = comment.mediaAttachment {
            mediaType           = mediaAttachment.type.rawValue
            mediaUrl            = mediaAttachment.url.absoluteString
            thumbnailUrl        = mediaAttachment.thumbnailURL?.absoluteString ?? thumbnailUrl
            mediaWidth          = mediaAttachment.size?.width ?? mediaWidth
            mediaHeight         = mediaAttachment.size?.height ?? mediaHeight
            shouldAutoplay      = mediaAttachment.shouldAutoplay
            
            // We MUST use the MP4 asset for gifs
            if mediaAttachment.type == .GIF {
                mediaUrl = mediaAttachment.mp4URLForMediaAttachment()?.absoluteString
            }
        }
        
        // Set the sequence and inStreamSequence based on the comment's sequenceID if a Sequence object isn't set
        if sequence == nil {
            sequence = v_managedObjectContext.v_findOrCreateObject([ "remoteId" : comment.sequenceID ]) as VSequence
            inStreamSequence = sequence
        }
        
        // Set the user based on the comment's user if a User object isn't set
        if user == nil {
            let parsedUser: VUser = v_managedObjectContext.v_findOrCreateObject([ "remoteId" : comment.user.id ])
            parsedUser.populate( fromSourceModel: comment.user )
            user = parsedUser
        }
    }
}
