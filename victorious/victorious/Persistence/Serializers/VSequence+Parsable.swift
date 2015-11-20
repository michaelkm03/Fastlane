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
        
        if let trackingModel = sequence.tracking {
            tracking = persistentStoreContext.createObject() as VTracking
            tracking?.populate(fromSourceModel: trackingModel)
        }
        
        if let endCardModel = sequence.endCard {
            endCard = persistentStoreContext.createObject() as VEndCard
            endCard?.populate(fromSourceModel: endCardModel)
        }
        
        user = persistentStoreContext.findOrCreateObject( [ "remoteId" : Int(sequence.user.userID) ] ) as VUser
        user?.populate(fromSourceModel: sequence.user)
        
        previewImageAssets = Set<VImageAsset>(sequence.previewImageAssets.flatMap {
            let imageAsset: VImageAsset = self.persistentStoreContext.findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
            imageAsset.populate( fromSourceModel: $0 )
            return imageAsset
        })
        
        nodes = NSOrderedSet(array: sequence.nodes.flatMap {
            let node: VNode = persistentStoreContext.findOrCreateObject([ "remoteId" : Int($0.nodeID)! ])
            node.populate( fromSourceModel: $0 )
            return node
        })
        
        let flaggedCommentIds: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment)?.flatMap { $0 as? Int64 } ?? []
        let allComments: [VComment] = sequence.comments.filter {
            flaggedCommentIds.contains($0.commentID) == false
        }.flatMap {
            let comment: VComment = self.persistentStoreContext.findOrCreateObject([ "remoteId" : String($0.commentID) ])
            comment.populate(fromSourceModel: $0)
            return comment
        }
        comments = NSOrderedSet(array: allComments)
    }
}
