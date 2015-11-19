//
//  VNode+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNode: PersistenceParsable {
    func populate( fromSourceModel node: Node ) {
        guard let remoteID = Int(node.nodeID) else {
            return
        }
        self.remoteId = NSNumber(integer: remoteID)
        
        assets = NSOrderedSet( array: node.assets.flatMap {
            let uniqueElements = [ "data" : $0.data ]
            let asset: VAsset = self.persistentStoreContext.findOrCreateObject( uniqueElements )
            asset.populate( fromSourceModel: $0 )
            return asset
        })
    }
}

extension VPollResult: PersistenceParsable {
    func populate( fromSourceModel voteResult: VoteResult ) {
        self.count = Int(voteResult.voteCount)
    }
}

extension VComment: PersistenceParsable {
    func populate( fromSourceModel comment: Comment ) {
        remoteId = Int(comment.commentID)
        shouldAutoplay = comment.shouldAutoplay
        text = comment.text
        mediaType = comment.mediaType?.rawValue
        mediaUrl = comment.mediaURL?.absoluteString
        thumbnailUrl = comment.thumbnailURL?.absoluteString
        flags = comment.flags
        postedAt = comment.postedAt
        
        user = persistentStoreContext.findOrCreateObject([ "remoteId" : Int(comment.user.userID) ]) as VUser
        user.populate( fromSourceModel: comment.user )
    }
}
