//
//  SequenceCommentsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceCommentsOperation: RequestOperation<SequenceCommentsRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let flaggedContent = VFlaggedContent()
    private let sequenceID: Int64
    
    init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.sequenceID = sequenceID
        super.init( request: SequenceCommentsRequest(sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage) )
    }
    
    init( sequenceID: Int64, request: SequenceCommentsRequest ) {
        self.sequenceID = sequenceID
        super.init(request: request)
    }
    
    var nextPageOperation: SequenceCommentsOperation?
    var previousPageOperation: SequenceCommentsOperation?
    
    override func onComplete(response: SequenceCommentsRequest.ResultType, completion:()->() ) {
        
        // TODO: Unit test the flagged content stuff
        let flaggedCommentIds: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment)?.flatMap { $0 as? Int64 } ?? []
        if response.results.count > 0 {
            persistentStore.asyncFromBackground() { context in
                var comments = [VComment]()
                for comment in response.results.filter({ flaggedCommentIds.contains($0.commentID) == false }) {
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
        
        dispatch_async( dispatch_get_main_queue() ) {
            if let nextPageRequest = response.nextPage {
                self.nextPageOperation = SequenceCommentsOperation( sequenceID: self.sequenceID, request: nextPageRequest )
            }
            if let previousPageRequest = response.previousPage {
                self.previousPageOperation = SequenceCommentsOperation( sequenceID: self.sequenceID, request: previousPageRequest )
            }
        }
    }
}
