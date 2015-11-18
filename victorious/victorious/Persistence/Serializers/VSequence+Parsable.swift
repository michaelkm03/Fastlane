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
        remoteId                = sequence.remoteID
        repostCount             = sequence.repostCount
        sequenceDescription     = sequence.sequenceDescription
        
        user = dataStore.findOrCreateObject( [ "remoteId" : Int(sequence.user.userID) ] ) as VUser
        user?.populate(fromSourceModel: sequence.user)
        
        previewImageAssets = Set<VImageAsset>(sequence.previewImageAssets.flatMap {
            let imageAsset: VImageAsset = self.dataStore.findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
            imageAsset.populate( fromSourceModel: $0 )
            return imageAsset
            })
        
        nodes = NSOrderedSet(array: sequence.nodes.flatMap {
            let node: VNode = dataStore.findOrCreateObject([ "remoteId" : Int($0.nodeID)! ])
            node.populate( fromSourceModel: $0 )
            return node
        })
    }
}
