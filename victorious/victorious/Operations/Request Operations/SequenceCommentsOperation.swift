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
    
    func onComplete( comments: SequenceCommentsRequest.ResultType, completion:()->() ) {
        guard !comments.isEmpty else {
            self.results = []
            completion()
            return
        }
        
        // Filter flagged comments here so that they never even make it into the persistent store
        let flaggedIDs: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int($0) }
        let unflaggedResults = comments.filter { flaggedIDs.contains($0.commentID) == false }
        
        // Make changes on background queue
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            var displayOrder = self.request.paginator.displayOrderCounterStart
            
            var newComments = [VComment]()
            for comment in unflaggedResults {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                persistentComment.sequenceId = self.sequenceID
                persistentComment.displayOrder = displayOrder++
                newComments.append( persistentComment )
            }
            sequence.v_addObjects( newComments, to: "comments" )
            
            context.v_save()
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VComment.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "sequence.remoteId == %@",
                vsdk_argumentArray: [self.sequenceID],
                vsdk_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}

class FetchCommentsOperation: FetcherOperation {
    
    let sequenceID: String
    let paginator: NumericPaginator
    
    init( sequenceID: String, paginator: NumericPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VComment.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "sequence.remoteId == %@",
                vsdk_argumentArray: [self.sequenceID],
                vsdk_paginator: self.paginator
            )
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VComment]
            return results
        }
    }
}
