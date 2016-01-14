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
    
    convenience init( sequenceID: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
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
            var displayOrder = self.startingDisplayOrder
            
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
            completion()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let existingComments: [VComment] = context.v_findObjects(["sequenceId" : self.sequenceID])
            for comment in existingComments {
                context.deleteObject( comment )
            }
            context.v_save()
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VComment.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                v_format: "sequenceId == %@",
                v_argumentArray: [self.sequenceID],
                v_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
