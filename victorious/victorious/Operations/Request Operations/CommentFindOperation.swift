//
//  CommentFindOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentFindOperation: RemoteFetcherOperation, RequestOperation {
    
    var request: CommentFindRequest!
    
    private let flaggedContent = VFlaggedContent()
    
    private let sequenceID: String
    private let commentID: Int
    
    var pageNumber: Int?
    
    init( sequenceID: String, commentID: Int, itemsPerPage: Int = 15 ) {
        self.sequenceID = sequenceID
        self.commentID = commentID
        self.request = CommentFindRequest(sequenceID: sequenceID, commentID: commentID, itemsPerPage: itemsPerPage)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
    
    private func onComplete( response: CommentFindRequest.ResultType, completion:()->() ) {
        self.pageNumber = response.pageNumber
        
        let flaggedCommentIds: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int($0) }
        if !response.comments.isEmpty {
            persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
                var comments = [VComment]()
                for comment in response.comments.filter({ flaggedCommentIds.contains($0.commentID) == false }) {
                    let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                    persistentComment.populate( fromSourceModel: comment )
                    comments.append( persistentComment )
                }
                let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
                sequence.comments = NSOrderedSet( array: sequence.comments.array + comments )
                context.v_save()
            }
            completion()
        }
    }
}
