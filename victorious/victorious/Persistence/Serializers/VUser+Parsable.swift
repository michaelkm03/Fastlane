//
//  VUser+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VUser: PersistenceParsable {
    
    func populate( fromSourceModel user: User ) {
        remoteId                    = Int(user.userID)
        email                       = user.email
        name                        = user.name
        status                      = user.status.rawValue
        location                    = user.location
        tagline                     = user.tagline
        isCreator                   = user.isCreator
        isDirectMessagingDisabled   = user.isDirectMessagingDisabled
        isFollowedByMainUser        = user.isFollowedByMainUser
        numberOfFollowers           = Int(user.numberOfFollowers)
        numberOfFollowing           = Int(user.numberOfFollowing)
        pictureUrl                  = user.profileImageURL
        tokenUpdatedAt              = user.tokenUpdatedAt
        maxUploadDuration           = Int(user.maxVideoUploadDuration)
        
        previewAssets = Set<VImageAsset>(user.previewImageAssets.flatMap {
            let imageAsset: VImageAsset = self.dataStore.findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
            imageAsset.populate( fromSourceModel: $0 )
            return imageAsset
        })
    }
}

extension VConversation: PersistenceParsable {
    
    func populate( fromSourceModel conversation: Conversation ) {
        isRead                      = conversation.isRead
        postedAt                    = conversation.postedAt
        remoteId                    = Int(conversation.conversationID)
        messages                    = NSOrderedSet()
    }
}

extension VMessage: PersistenceParsable {
    
    func populate( fromSourceModel message: Message ) {
        mediaPath                   = message.mediaURL?.absoluteString ?? ""
        postedAt                    = message.postedAt
        remoteId                    = Int(message.messageID)
        //senderUserId                = message.senderUserId
        text                        = message.text
        //thumbnailPath               = message.thumbnailPath
        isRead                      = message.isRead
        //conversation                = message.conversation
        //notification                = message.notification
        //sender                      = message.sender
        //mediaAttachments            = message.mediaAttachments
        shouldAutoplay              = message.shouldAutoplay
        //mediaWidth                  = message.mediaWidth
        //mediaHeight                 = message.mediaHeight
    }
}

