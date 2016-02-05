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
    
    func populate( fromSourceModel sourceModel: (sequence: Sequence, streamID: String?) ) {
        
        let sequence = sourceModel.sequence
        let streamID = sourceModel.streamID
        
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
        itemSubType             = sequence.subtype?.rawValue
        releasedAt              = sequence.releasedAt ?? releasedAt
        
        guard let context = self.managedObjectContext else {
            return
        }

        if let adBreak = sequence.adBreak {
            let persistentAdBreak = context.v_createObject() as VAdBreak
            persistentAdBreak.populate(fromSourceModel: adBreak)
            self.adBreak = persistentAdBreak
        }
        
        if let trackingData = sequence.tracking {
            let uniqueInfo: [String : NSObject]
            if let streamID = streamID {
                let stream: VStream = context.v_findOrCreateObject([ "remoteId" : streamID])
                uniqueInfo = ["streamItem" : self, "streamParent" : stream, "marqueeParent" : "nil"]
            } else {
                // If no streaID was provided, parse out a VStreamChild with no stream parents
                // to hold it.  This will be made available for tracking code that has no stream context,
                // such as a deeplinked sequence or the lightweight content view sequence.
                uniqueInfo = ["streamItem" : self, "streamParent" : "nil", "marqueeParent" : "nil"]
            }
            let streamChild: VStreamChild = context.v_findOrCreateObject( uniqueInfo )
            streamChild.streamItem = self
            
            let tracking = context.v_createObject() as VTracking
            tracking.populate(fromSourceModel: trackingData)
            streamChild.tracking = tracking
        }

        self.user = context.v_findOrCreateObject( [ "remoteId" : sequence.user.userID ] ) as VUser
        self.user.populate(fromSourceModel: sequence.user)
        
        if let parentUser = sequence.parentUser {
            self.parentUserId = NSNumber(integer: parentUser.userID)
            let persistentParentUser = context.v_findOrCreateObject([ "remoteId" : parentUser.userID ]) as VUser
            persistentParentUser.populate(fromSourceModel: parentUser)
            self.parentUser = persistentParentUser
        }
        
        if let previewImageAssets = sequence.previewImageAssets where previewImageAssets.count > 0 {
            let persistentAssets: [VImageAsset] = previewImageAssets.flatMap {
                let imageAsset: VImageAsset = context.v_findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
            }
            self.previewImageAssets = Set<VImageAsset>(persistentAssets)
        }
        
        if let nodes = sequence.nodes where nodes.count > self.nodes?.count {
            let persistentNodes: [VNode] = nodes.flatMap {
                let node: VNode = context.v_createObject()
                node.populate( fromSourceModel: $0 )
                node.sequence = self
                return node
            }
            self.nodes = NSOrderedSet(array: persistentNodes)
        }
    }
}
