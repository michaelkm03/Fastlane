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
        previewImagesObject     = sequence.previewImagesObject ?? previewImagesObject
        repostCount             = sequence.repostCount ?? repostCount
        sequenceDescription     = sequence.sequenceDescription ?? sequenceDescription
        releasedAt              = sequence.releasedAt ?? releasedAt
        
        if let trackingModel = sequence.tracking {
            tracking = v_managedObjectContext.v_createObject() as VTracking
            tracking?.populate(fromSourceModel: trackingModel)
        }
        
        
        self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : sequence.user.userID ] ) as VUser

        self.user.populate(fromSourceModel: sequence.user)
        
        if let previewImageAssets = sequence.previewImageAssets {
            self.previewImageAssets = Set<VImageAsset>(previewImageAssets.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
            })
        }
        
        if let nodes = sequence.nodes {
            self.nodes = NSOrderedSet(array: nodes.flatMap {
                let node: VNode = v_managedObjectContext.v_findOrCreateObject([ "remoteId" : $0.nodeID ])
                node.populate( fromSourceModel: $0 )
                return node
            })
        }
        
        if let comments = sequence.comments {
            let flaggedIds = VFlaggedContent().flaggedContentIdsWithType(.Comment)
            let unflaggedComments = comments.filter { !flaggedIds.contains(String($0.commentID)) }
            let persistentComments: [VComment] = unflaggedComments.map {
                let comment: VComment = self.v_managedObjectContext.v_findOrCreateObject([ "remoteId" : NSNumber(long: $0.commentID) ])
                comment.populate(fromSourceModel: $0)
                return comment
            }
            self.v_addObjects( persistentComments, to: "comments")
        }
    }
}
