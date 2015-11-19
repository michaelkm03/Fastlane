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
            let imageAsset: VImageAsset = self.persistentStoreContext.findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
            imageAsset.populate( fromSourceModel: $0 )
            return imageAsset
        })
    }
}
