//
//  SequenceLikersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceLikersOperation: RequestOperation, PaginatedOperation {
    
    let request: SequenceLikersRequest
    
    private var sequenceID: String
    
    required init( request: SequenceLikersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: SequenceLikersRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( users: SequenceLikersRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart

            let sequence: VSequence = context.v_findOrCreateObject(["remoteId" : self.sequenceID ])
            for user in users {
                let persistentUser: VUser = context.v_findOrCreateObject( ["remoteId" : user.userID ] )
                persistentUser.populate(fromSourceModel: user)

                let uniqueElements = [ "sequence"  : sequence, "user" : persistentUser ]
                let userSequenceContext: VSequenceLiker = context.v_findOrCreateObject( uniqueElements )
                userSequenceContext.sequence = sequence
                userSequenceContext.user = persistentUser
                userSequenceContext.displayOrder = displayOrder++
            }
            context.v_save()
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    // MARK: - PaginatedOperation
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VSequenceLiker.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "sequence.remoteId = %@",
                vsdk_argumentArray: [ self.sequenceID ],
                vsdk_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            let results: [VSequenceLiker] = context.v_executeFetchRequest( fetchRequest )
            return results.map { $0.user }
        }
    }
}
