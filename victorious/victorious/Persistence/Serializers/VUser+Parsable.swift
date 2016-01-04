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
        remoteId                    = NSNumber( longLong: user.userID)
        status                      = user.status == nil ? status : user.status!.rawValue
        email                       = user.email == nil ? email : user.email!
        name                        = user.name == nil ? name : user.name!
        location                    = user.location == nil ? location : user.location!
        tagline                     = user.tagline == nil ? tagline : user.tagline!
        isCreator                   = user.isCreator == nil ? isCreator : user.isCreator!
        isDirectMessagingDisabled   = user.isDirectMessagingDisabled == nil ? isDirectMessagingDisabled : user.isDirectMessagingDisabled!
        isFollowedByMainUser        = user.isFollowedByMainUser == nil ? isFollowedByMainUser : user.isFollowedByMainUser!
        pictureUrl                  = user.profileImageURL == nil ? pictureUrl : user.profileImageURL!
        tokenUpdatedAt              = user.tokenUpdatedAt == nil ? tokenUpdatedAt : user.tokenUpdatedAt!
        maxUploadDuration           = user.maxVideoUploadDuration == nil ? maxUploadDuration : NSNumber( longLong: user.maxVideoUploadDuration)
        numberOfFollowers           = user.numberOfFollowers == nil ? numberOfFollowers : NSNumber( longLong: user.numberOfFollowers! )
        numberOfFollowing           = user.numberOfFollowing == nil ? numberOfFollowing : NSNumber( longLong: user.numberOfFollowing! )
        
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
