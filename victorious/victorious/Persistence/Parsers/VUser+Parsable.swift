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
        remoteId                    = user.userID ?? user.userID
        status                      = user.status?.rawValue ?? status
        email                       = user.email ?? email
        name                        = user.name ?? name
        location                    = user.location ?? location
        tagline                     = user.tagline ?? tagline
        isCreator                   = user.isCreator ?? isCreator
        isDirectMessagingDisabled   = user.isDirectMessagingDisabled ?? isDirectMessagingDisabled
        isFollowedByMainUser        = user.isFollowedByMainUser ?? isFollowedByMainUser
        pictureUrl                  = user.profileImageURL ?? pictureUrl
        tokenUpdatedAt              = user.tokenUpdatedAt ?? tokenUpdatedAt
        maxUploadDuration           = user.maxVideoUploadDuration ?? maxUploadDuration
        numberOfFollowers           = user.numberOfFollowers ?? numberOfFollowers
        numberOfFollowing           = user.numberOfFollowing ?? numberOfFollowing
        levelProgressPoints         = user.fanLoyalty?.points ?? levelProgressPoints
        level                       = user.fanLoyalty?.level ?? level
        levelProgressPercentage     = user.fanLoyalty?.progress ?? levelProgressPercentage        
        avatarBadgeType             = user.avatar?.badgeType ?? avatarBadgeType
        
        if let previewImageAssets = user.previewImageAssets where !previewImageAssets.isEmpty {
            let newPreviewAssets: [VImageAsset] = previewImageAssets.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
            }
            self.v_addObjects( newPreviewAssets, to: "previewAssets" )
        }
    }
}
