//
//  SequenceCommentsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceCommentsOperation: RequestOperation, PaginatedOperation, ResultsOperation {
    
    var request: SequenceCommentsRequest
    var resultCount: Int?
    
    private let sequenceID: Int64
    
    private(set) var results: [AnyObject]?
    
    required init( request: SequenceCommentsRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: SequenceCommentsRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            let results = loadPersistentItems()
            self.results = results
            self.resultCount = results.count
            
        } else {
            self.resultCount = 0
        }
        completion()
    }
    
    private func onComplete( comments: SequenceCommentsRequest.ResultType, completion:()->() ) {
        self.resultCount = comments.count
        
        guard !comments.isEmpty else {
            completion()
            return
        }
        
        let flaggedCommentIDs: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int64($0) }
        let unflaggedCommens = comments.filter { flaggedCommentIDs.contains($0.commentID) == false }
        
        persistentStore.backgroundContext.v_performBlock() { context in
            var newComments = [VComment]()
            for comment in unflaggedCommens {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                newComments.append( persistentComment )
            }
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
            sequence.v_addObjects( newComments, to: "comments")
            // TODO: Sort here, we must!
            context.v_save()
            
            dispatch_async( dispatch_get_main_queue() ) {
                let results = self.loadPersistentItems()
                self.results = results
                self.resultCount = results.count
                completion()
            }
        }
    }
    
    private func loadPersistentItems() -> [VComment] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueProps = [ "sequenceId" : String(self.sequenceID) ] // FIXME: Use `sequence` property isntead of `sequenceId`
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber
            )
            return context.v_findObjects( uniqueProps, pagination: pagination )
        }
    }
}
