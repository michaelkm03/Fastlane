//
//  VSequence+Serializable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VSequence: DataStoreObject {
    // Will need to implement `entityName` when +RestKit categories are removed
}

extension VSequence: Serializable {
    
    func serialize( streamItem: StreamItemType, dataStore: DataStore ) {
        guard let sequence = streamItem as? Sequence else {
            return
        }
        
        category                = sequence.category.rawValue
        commentCount            = sequence.commentCount
        gifCount                = sequence.gifCount
        hasReposted             = sequence.hasReposted
        isComplete              = sequence.isComplete
        isLikedByMainUser       = sequence.isLikedByMainUser
        isRemix                 = sequence.isRemix
        isRepost                = sequence.isRepost
        likeCount               = sequence.likeCount
        memeCount               = sequence.memeCount
        name                    = sequence.name
        nameEmbeddedInContent   = sequence.nameEmbeddedInContent
        permissionsMask         = sequence.permissionsMask
        previewImagesObject     = sequence.previewImagesObject
        remoteId                = sequence.remoteId
        repostCount             = sequence.repostCount
        sequenceDescription     = sequence.sequenceDescription
       
        
        user = dataStore.findOrCreateObject( [ "remoteId" : Int(sequence.user.userID) ] ) as VUser
        
        previewImageAssets = Set<VImageAsset>(sequence.previewImageAssets.flatMap {
            let imageAsset: VImageAsset = dataStore.findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
            imageAsset.serialize( $0, dataStore: dataStore )
            return imageAsset
        })
        
        nodes = NSOrderedSet(array: sequence.nodes.flatMap {
            let node: VNode = dataStore.findOrCreateObject([ "remoteId" : Int($0.nodeId)! ])
            node.serialize( $0, dataStore: dataStore )
            return node
        })
    }
}
