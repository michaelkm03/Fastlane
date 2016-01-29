//
//  VSequence+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VSequence: PersistenceParsable {
    
    func populate( fromSourceModel streamItem: StreamItemType ) {
        guard let sequence = streamItem as? Sequence else {
            return
        }
        remoteId                = sequence.sequenceID
        category                = sequence.category.rawValue
        
        isGifStyle              = sequence.isGifStyle ?? isGifStyle
        commentCount            = sequence.commentCount ?? commentCount
        gifCount                = sequence.gifCount ?? gifCount
        hasReposted             = sequence.hasReposted ?? hasReposted
        isComplete              = sequence.isComplete ?? isComplete
        isRemix                 = sequence.isRemix ?? isRemix
        isRepost                = sequence.isRepost ?? isRepost
        likeCount               = sequence.likeCount ?? likeCount
        memeCount               = sequence.memeCount ?? memeCount
        name                    = sequence.name ?? name
        nameEmbeddedInContent   = sequence.nameEmbeddedInContent ?? nameEmbeddedInContent
        permissionsMask         = sequence.permissionsMask ?? permissionsMask
        repostCount             = sequence.repostCount ?? repostCount
        sequenceDescription     = sequence.sequenceDescription ?? sequenceDescription
        releasedAt              = sequence.releasedAt ?? releasedAt
        trendingTopicName       = sequence.trendingTopicName ?? trendingTopicName
        isLikedByMainUser       = sequence.isLikedByMainUser ?? isLikedByMainUser
        headline                = sequence.headline ?? headline
        previewData             = sequence.previewData ?? previewData
        previewType             = sequence.previewType?.rawValue
        previewImagesObject     = sequence.previewImagesObject ?? previewImagesObject
        itemType                = sequence.type?.rawValue
        itemSubType             = sequence.type?.rawValue
        releasedAt              = sequence.releasedAt ?? releasedAt
        
        // TODO: parse AdBreaks, previewTextPostAsset
        
        if let trackingModel = sequence.tracking {
            tracking = v_managedObjectContext.v_createObject() as VTracking
            tracking?.populate(fromSourceModel: trackingModel)
        }
        
        self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : sequence.user.userID ] ) as VUser
        self.user.populate(fromSourceModel: sequence.user)
        
        if let parentUser = sequence.parentUser {
            self.parentUserId = NSNumber(integer: parentUser.userID)
            let persistentParentUser = v_managedObjectContext.v_findOrCreateObject([ "remoteId" : parentUser.userID ]) as VUser
            persistentParentUser.populate(fromSourceModel: parentUser)
            self.parentUser = persistentParentUser
        }
        
        if let previewImageAssets = sequence.previewImageAssets where previewImageAssets.count > 0 {
            self.previewImageAssets = Set<VImageAsset>(previewImageAssets.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
                })
        }
        
        if let nodes = sequence.nodes where !nodes.isEmpty && (self.nodes ?? []).count == 0 {
            self.nodes = NSOrderedSet(array: nodes.flatMap {
                let node: VNode = v_managedObjectContext.v_createObject()
                node.populate( fromSourceModel: $0 )
                return node
            })
        }
    }
}
