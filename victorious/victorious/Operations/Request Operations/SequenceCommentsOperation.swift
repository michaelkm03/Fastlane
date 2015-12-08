//
//  SequenceCommentsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceCommentsOperation: RequestOperation, PageableOperationType {
    
    var currentRequest: SequenceCommentsRequest
    
    private let sequenceID: Int64
    
    required init( request: SequenceCommentsRequest ) {
        self.sequenceID = request.sequenceID
        self.currentRequest = request
    }
    
    convenience init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: SequenceCommentsRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( comments: SequenceCommentsRequest.ResultType, completion:()->() ) {
        
        let flaggedCommentIds: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment)?.flatMap { $0 as? Int64 } ?? []
        if comments.count > 0 {
            persistentStore.asyncFromBackground() { context in
                var newComments = [VComment]()
                for comment in comments.filter({ flaggedCommentIds.contains($0.commentID) == false }) {
                    let persistentComment: VComment = context.findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                    persistentComment.populate( fromSourceModel: comment )
                    newComments.append( persistentComment )
                }
                let sequence: VSequence = context.findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
                sequence.comments = NSOrderedSet( array: sequence.comments.array + newComments )
                context.saveChanges()
            }
            completion()
        }
    }
}
