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
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    private let sequenceID: String
    
    required init( request: SequenceCommentsRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: SequenceCommentsRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
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
        
        // Filter flagged comments here so that they never even make it into the persistent store
        let flaggedCommentIDs: [Int64] = VFlaggedContent().flaggedContentIdsWithType(.Comment).flatMap { Int64($0) }
        let unflaggedComments = comments.filter { flaggedCommentIDs.contains($0.commentID) == false }
        
        // Make changes on background queue
        persistentStore.backgroundContext.v_performBlock() { context in
            
            // If refreshing with a network connection, delete everything we have
            // TODO: revising how this fits into 4.0 architecture.
            if self.hasNetworkConnection && self.request.paginator.pageNumber == 1 {
                let existingComments: [VComment] = context.v_findObjects(["sequenceId" : self.sequenceID])
                for comment in existingComments {
                    context.deleteObject( comment )
                }
                context.v_save()
            }
            
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            
            var newComments = [VComment]()
            for comment in unflaggedComments {
                let persistentComment: VComment = context.v_findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                persistentComment.sequenceId = self.sequenceID
                persistentComment.displayOrder = displayOrder++
                newComments.append( persistentComment )
            }
            sequence.v_addObjects( newComments, to: "comments" )
            context.v_save()
            
            self.results = self.fetchResults()
            completion()
        }
    }
    
    func fetchResults() -> [VComment] {
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
    
    private var hasNetworkConnection: Bool {
        return VReachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
    }
}
