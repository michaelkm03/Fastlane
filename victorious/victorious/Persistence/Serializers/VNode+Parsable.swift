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
        guard let remoteID = Int64(node.nodeID) else {
            return
        }
        self.remoteId = NSNumber(longLong: remoteID)
        
        assets = NSOrderedSet( array: node.assets.flatMap {
            let uniqueElements = [ "data" : $0.data ]
            let asset: VAsset = self.persistentStoreContext.findOrCreateObject( uniqueElements )
            asset.populate( fromSourceModel: $0 )
            return asset
        })
    }
}

extension VComment: PersistenceParsable {
    func populate( fromSourceModel comment: Comment ) {
        remoteId = NSNumber(longLong: comment.commentID)
        shouldAutoplay = comment.shouldAutoplay
        text = comment.text
        mediaType = comment.mediaType?.rawValue
        mediaUrl = comment.mediaURL?.absoluteString
        thumbnailUrl = comment.thumbnailURL?.absoluteString
        flags = comment.flags
        postedAt = comment.postedAt
        
        user = persistentStoreContext.findOrCreateObject([ "remoteId" : NSNumber(longLong:comment.user.userID) ]) as VUser
        user.populate( fromSourceModel: comment.user )
    }
}
