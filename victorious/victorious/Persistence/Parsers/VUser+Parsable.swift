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
    func populate(fromSourceModel user: UserModel) {
        remoteId                    = user.id ?? remoteId
        v_completedProfile          = user.completedProfile ?? completedProfile
        email                       = user.email ?? email
        name                        = user.name ?? name
        location                    = user.location ?? location
        tagline                     = user.tagline ?? tagline
        isBlockedByMainUser         = user.isBlockedByCurrentUser ?? isBlockedByMainUser
        isVIPSubscriber             = user.vipStatus?.isVIP ?? isVIPSubscriber
        vipEndDate                  = user.vipStatus?.endDate ?? vipEndDate
        isCreator                   = user.accessLevel.isCreator ?? isCreator
        isFollowedByMainUser        = user.isFollowedByCurrentUser ?? isFollowedByMainUser
        v_likesGiven                = user.likesGiven ?? likesGiven
        v_likesReceived             = user.likesReceived ?? likesReceived
        levelProgressPoints         = user.fanLoyalty?.points ?? levelProgressPoints
        level                       = user.fanLoyalty?.level ?? level
        levelProgressPercentage     = user.fanLoyalty?.progress ?? levelProgressPercentage
        tier                        = user.fanLoyalty?.tier ?? tier
        achievementsUnlocked        = user.fanLoyalty?.achievementsUnlocked ?? achievementsUnlocked
        v_avatarBadgeType           = user.avatarBadgeType?.stringRepresentation ?? v_avatarBadgeType
        
        if let vipStatus = user.vipStatus {
            populateVIPStatus(fromSourceModel: vipStatus)
        }
        
        if !user.previewImages.isEmpty {
            let newPreviewAssets: [VImageAsset] = user.previewImages.flatMap { imageAsset in
                guard let assetURL = imageAsset.url else {
                    return nil
                }
                let persistentImageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject(["imageURL": assetURL.absoluteString])
                persistentImageAsset.populate(fromSourceModel: imageAsset)
                return persistentImageAsset
            }
            self.v_addObjects( newPreviewAssets, to: "previewAssets" )
        }
    }
    
    func clearVIPStatus() {
        isVIPSubscriber = false
        vipEndDate = nil
    }
    
    func populateVIPStatus(fromSourceModel vipStatus: VIPStatus) {
        // If the user already is a VIP, we do not want to undo that.  We only want
        // to update the status if the existing value is undefined (nil) or false.
        // The purposes of this is to allow the user to remain a VIP for the duration of
        // their session even if their subscription expires during the session.
        // Upon the next session, the user will not be a VIP and must re-subscribe.
        if isVIPSubscriber == false {
            isVIPSubscriber = vipStatus.isVIP
        }
    }
}
