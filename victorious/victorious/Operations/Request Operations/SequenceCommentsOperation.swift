//
//  SequenceCommentsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceCommentsOperation: RequestOperation, PaginatedOperation {
    
    var request: SequenceCommentsRequest
    var results: [AnyObject]?
    
    private let sequenceID: String
    
    required init( request: SequenceCommentsRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: SequenceCommentsRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
            
        } else {
            self.results = []
        }
        completion()
    }
    
    func onComplete( comments: SequenceCommentsRequest.ResultType, completion:()->() ) {
        guard !comments.isEmpty else {
            self.results = []
            completion()
            return
        }
        
        let flaggedCommentIDs: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int64($0) }
        let unflaggedCommens = comments.filter { flaggedCommentIDs.contains($0.commentID) == false }
        
        // Make changes on background queue
        persistentStore.backgroundContext.v_performBlock() { context in
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            
            var newComments = [VComment]()
            for comment in unflaggedCommens {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                
                // Handle some special properties here that determine proper display order
                persistentComment.displayOrder = displayOrder++
                
                newComments.append( persistentComment )
            }
            sequence.v_addObjects( newComments, to: "comments" )
            context.v_save()
            
            // Reload results from main queue
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    func fetchResults() -> [VComment] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
            let uniqueProps = [ "sequence" : sequence ]
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber,
                sortDescriptors: [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            )
            return context.v_findObjects( uniqueProps, pagination: pagination )
        }
    }
}
