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
    
    func populate( fromSourceModel sourceModel: Sequence ) {
        let sequence = sourceModel
        
        remoteId                = sequence.sequenceID
        category                = sequence.category.rawValue
        
        isGifStyle              = sequence.isGifStyle ?? isGifStyle
        commentCount            = sequence.commentCount ?? commentCount
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
        previewData             = sequence.previewData ?? previewData
        previewType             = sequence.previewType?.rawValue
        previewImagesObject     = sequence.previewImagesObject ?? previewImagesObject
        itemType                = sequence.type?.rawValue
        itemSubType             = sequence.subtype?.rawValue
        
        guard let context = self.managedObjectContext else {
            return
        }

        if let adBreak = sequence.adBreak {
            let persistentAdBreak = context.v_createObject() as VAdBreak
            persistentAdBreak.populate(fromSourceModel: adBreak)
            self.adBreak = persistentAdBreak
        }

        self.user = context.v_findOrCreateObject( [ "remoteId" : sequence.user.id ] ) as VUser
        self.user.populate(fromSourceModel: sequence.user)
        
        if let parentUser = sequence.parentUser {
            self.parentUserId = NSNumber(integer: parentUser.id)
            let persistentParentUser = context.v_findOrCreateObject([ "remoteId": parentUser.id ]) as VUser
            persistentParentUser.populate(fromSourceModel: parentUser)
            self.parentUser = persistentParentUser
        }
        
        if let textPostAsset = sequence.previewAsset where textPostAsset.type == .Text {
            let persistentAsset: VAsset = v_managedObjectContext.v_createObject()
            persistentAsset.populate(fromSourceModel: textPostAsset)
            previewTextPostAsset = persistentAsset
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
        
        if let previewImageAssets = sourceModel.previewImageAssets {
            let persistentAssets: [VImageAsset] = previewImageAssets.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
            }
            self.previewImageAssets = Set<VImageAsset>(persistentAssets)
        }
        
        if let voteResults = sequence.voteTypes where !voteResults.isEmpty {
            self.voteResults = Set<VVoteResult>(voteResults.flatMap {
                guard let id = Int($0.voteID) else {
                    return nil
                }
                let uniqueElements: [String : AnyObject] = [
                    "sequence.remoteId": remoteId,
                    "remoteId": NSNumber(integer: id)
                ]
                
                let persistentVoteResult: VVoteResult = self.v_managedObjectContext.v_findOrCreateObject(uniqueElements)
                persistentVoteResult.sequence = self
                persistentVoteResult.count = $0.voteCount
                return persistentVoteResult
            })
        }
    }
}

private extension VStreamItem {
    
    func parseStreamItemPointerForStream(stream: Stream) -> VStreamItemPointer {
        let uniqueInfo: [String : NSObject]
        if let apiPath = stream.apiPath {
            let stream: VStream = v_managedObjectContext.v_findOrCreateObject( [ "apiPath" : apiPath ] )
            uniqueInfo = ["streamItem": self, "streamParent": stream]
        } else {
            // If no `streamID` was provided, parse out an "empty" VStreamItemPointer,
            // i.e. one that points to a VStreamItem but has no associated streamParent
            // This is made available for calling code that has no reference to a stream,
            // such as a deeplinked sequence or the lightweight content view sequence.
            uniqueInfo = ["streamItem": self]
        }
        return v_managedObjectContext.v_findOrCreateObject( uniqueInfo )
    }
}
