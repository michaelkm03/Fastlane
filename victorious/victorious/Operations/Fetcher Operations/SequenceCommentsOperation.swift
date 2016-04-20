//
//  SequenceCommentsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceCommentsRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: SequenceCommentsRequest
    
    private let sequenceID: String
    
    required init( request: SequenceCommentsRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: SequenceCommentsRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( comments: SequenceCommentsRequest.ResultType) {
        guard !comments.isEmpty else {
            self.results = []
            return
        }
        
        // Filter flagged comments here so that they never even make it into the persistent store
        let flaggedIDs: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int($0) }
        let unflaggedResults = comments.filter { flaggedIDs.contains($0.commentID) == false }
        
        // Make changes on background queue
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            var displayOrder = self.request.paginator.displayOrderCounterEnd
            
            var newComments = [VComment]()
            for comment in unflaggedResults {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                persistentComment.sequenceId = self.sequenceID
                persistentComment.displayOrder = displayOrder
                displayOrder -= 1
                newComments.append( persistentComment )
            }
            sequence.v_addObjects( newComments, to: "comments" )
            
            context.v_save()
        }
    }
}
