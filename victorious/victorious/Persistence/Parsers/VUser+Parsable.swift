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
        remoteId                    = user.id ?? remoteId
        completedProfile            = user.completedProfile ?? completedProfile
        email                       = user.email ?? email
        name                        = user.name ?? name
        location                    = user.location ?? location
        tagline                     = user.tagline ?? tagline
        isBlockedByMainUser         = user.isBlockedByCurrentUser ?? isBlockedByMainUser
        isVIPSubscriber             = user.vipStatus?.isVIP ?? isVIPSubscriber
        vipEndDate                  = user.vipStatus?.endDate ?? vipEndDate
        isCreator                   = user.accessLevel?.isCreator ?? isCreator
        isDirectMessagingDisabled   = user.isDirectMessagingDisabled ?? isDirectMessagingDisabled
        isFollowedByMainUser        = user.isFollowedByCurrentUser ?? isFollowedByMainUser
        tokenUpdatedAt              = user.tokenUpdatedAt ?? tokenUpdatedAt
        maxUploadDuration           = user.maxVideoUploadDuration ?? maxUploadDuration
        numberOfFollowers           = user.numberOfFollowers ?? numberOfFollowers
        numberOfFollowing           = user.numberOfFollowing ?? numberOfFollowing
        likesGiven                  = user.likesGiven ?? likesGiven
        likesReceived               = user.likesReceived ?? likesReceived
        levelProgressPoints         = user.fanLoyalty?.points ?? levelProgressPoints
        level                       = user.fanLoyalty?.level ?? level
        levelProgressPercentage     = user.fanLoyalty?.progress ?? levelProgressPercentage
        tier                        = user.fanLoyalty?.tier ?? tier
        achievementsUnlocked        = user.fanLoyalty?.achievementsUnlocked ?? achievementsUnlocked
        avatarBadgeType             = user.avatarBadgeType.stringRepresentation
        
        if let vipStatus = user.vipStatus {
            populateVIPStatus(fromSourceModel: vipStatus)
        }
        
        if !user.previewImages.isEmpty {
            let newPreviewAssets: [VImageAsset] = user.previewImages.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
            }
            self.v_addObjects( newPreviewAssets, to: "previewAssets" )
        }
    }
    
    func clearVIPStatus() {
        isVIPSubscriber = false
        vipEndDate = nil
    }
    
    func populateVIPStatus( fromSourceModel vipStatus: VIPStatus ) {
        // If the user already is a VIP, we do not want to undo that.  We only want
        // to update the status if the existing value is undefined (nil) or false.
        // The purposes of this is to allow the user to remain a VIP for the duration of
        // their session even if their subscription expires during the session.
        // Upon the next session, the user will not be a VIP and must re-subscribe.
        if !isVIPSubscriber.boolValue {
            isVIPSubscriber = vipStatus.isVIP
        }
    }
}
