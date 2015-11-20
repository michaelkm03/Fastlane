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
    
    private let persistentStore = PersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        super.init( request: SequenceCommentsRequest(sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage) )
    }
    
    override init( request: SequenceCommentsRequest ) {
        super.init(request: request)
    }
    
    var nextPageOperation: SequenceCommentsOperation?
    var previousPageOperation: SequenceCommentsOperation?
    
    override func onResponse(response: SequenceCommentsRequest.ResultType) {
        
        // TODO: Unit test the flagged content stuff
        let flaggedCommentIds: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment)?.flatMap { $0 as? Int64 } ?? []
        persistentStore.syncFromBackground() { context in
            let sequences: [VSequence] = context.findObjects( [ "remoteId" : Int(self.request.sequenceID) ] )
            for comment in response.results.filter({ flaggedCommentIds.contains($0.commentID) == false }) {
                let persistentComment: VComment = context.findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                for sequence in sequences {
                    persistentComment.sequence = sequence
                    persistentComment.sequenceId = sequence.remoteId
                    persistentComment.userId = sequence.user?.remoteId
                }
            }
            
            dispatch_sync( dispatch_get_main_queue() ) {
                if let nextPageRequest = response.nextPage {
                    self.nextPageOperation = SequenceCommentsOperation( request: nextPageRequest )
                }
                if let previousPageRequest = response.previousPage {
                    self.previousPageOperation = SequenceCommentsOperation( request: previousPageRequest )
                }
            }
            
            context.saveChanges()
        }
    }
}
