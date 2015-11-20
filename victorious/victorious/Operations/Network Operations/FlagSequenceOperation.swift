//
//  FlagSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagSequenceOperation: RequestOperation<FlagContentRequest> {
    
    private let sequenceID: Int64
    private let persistentStore = PersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: Int64 ) {
        self.sequenceID = sequenceID
        super.init( request: FlagContentRequest(sequenceID: sequenceID) )
    }
    
    override func onResponse(response: FlagContentRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            if let sequence: VSequence = context.findObjects([ "remoteId" : String(self.sequenceID) ]).first {
                context.destroy( sequence )
                context.saveChanges()
            }
        }
    }
    
    override func onComplete(error: NSError?) {
        flaggedContent.addRemoteId( String(self.sequenceID), toFlaggedItemsWithType: .StreamItem)
    }
}

class FlagCommentOperation: RequestOperation<FlagContentRequest> {
    
    private let commentID: Int64
    private let persistentStore = PersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int64 ) {
        self.commentID = commentID
        super.init( request: FlagContentRequest(commentID: commentID) )
    }
    
    override func onResponse(response: FlagContentRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            if let comment: VComment = context.findObjects([ "remoteId" : String(self.commentID) ]).first {
                context.destroy( comment )
                context.saveChanges()
            }
        }
    }
    
    override func onComplete(error: NSError?) {
        flaggedContent.addRemoteId( String(self.commentID), toFlaggedItemsWithType: .Comment)
    }
}
