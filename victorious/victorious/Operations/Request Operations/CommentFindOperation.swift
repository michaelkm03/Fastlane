//
//  CommentFindOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentFindOperation: RequestOperation<CommentFindRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    private let sequenceID: Int64
    private let commentID: Int64
    
    var pageNumber: Int?
    
    init( sequenceID: Int64, commentID: Int64, itemsPerPage: Int = 15 ) {
        self.sequenceID = sequenceID
        self.commentID = commentID
        super.init( request: CommentFindRequest(sequenceID: sequenceID, commentID: commentID, itemsPerPage: itemsPerPage) )
    }
    
    override func onComplete(response: CommentFindRequest.ResultType, completion:()->() ) {
        self.pageNumber = response.pageNumber
        
        // TODO: Unit test the flagged content stuff
        let flaggedCommentIds: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment)?.flatMap { $0 as? Int64 } ?? []
        if response.comments.count > 0 {
            persistentStore.asyncFromBackground() { context in
                var comments = [VComment]()
                for comment in response.comments.filter({ flaggedCommentIds.contains($0.commentID) == false }) {
                    let persistentComment: VComment = context.findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                    persistentComment.populate( fromSourceModel: comment )
                    comments.append( persistentComment )
                }
                let sequence: VSequence = context.findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
                sequence.comments = NSOrderedSet( array: sequence.comments.array + comments )
                context.saveChanges()
            }
            completion()
        }
    }
}
