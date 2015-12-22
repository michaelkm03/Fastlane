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
    
    private let sequenceID: Int64
    
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
            self.results = loadPersistentItems()
            
        } else {
            self.results = []
        }
        completion()
    }
    
    private func onComplete( comments: SequenceCommentsRequest.ResultType, completion:()->() ) {
        guard !comments.isEmpty else {
            completion()
            return
        }
        
        let flaggedCommentIDs: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int64($0) }
        let unflaggedCommens = comments.filter { flaggedCommentIDs.contains($0.commentID) == false }
        
        // Make changes on background queue
        persistentStore.backgroundContext.v_performBlock() { context in
            var newComments = [VComment]()
            for comment in unflaggedCommens {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                newComments.append( persistentComment )
            }
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : String(self.sequenceID) ] )
            sequence.v_addObjects( newComments, to: "comments")
            context.v_save()
            
            // Reload results from main queue
            let objectIDs = newComments.map { $0.objectID }
            self.persistentStore.mainContext.v_performBlock() { context in
                self.results = objectIDs.flatMap { context.objectWithID($0) as? VComment }
                completion()
            }
        }
    }
    
    private func loadPersistentItems() -> [VComment] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueProps = [ "sequenceId" : String(self.sequenceID) ]
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber,
                sortDescriptors: [ NSSortDescriptor(key: "postedAt", ascending: false) ]
            )
            return context.v_findObjects( uniqueProps, pagination: pagination )
        }
    }
}
