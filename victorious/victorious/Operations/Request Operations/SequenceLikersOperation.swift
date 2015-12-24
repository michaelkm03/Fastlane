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
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    required init( request: SequenceLikersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: SequenceLikersRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
        } else {
            self.results = []
        }
        completion()
    }
    
    private func onComplete( users: SequenceLikersRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage

            let sequence: VSequence = context.v_findOrCreateObject(["remoteId" : String(self.sequenceID) ])
            for user in users {
                let persistentUser: VUser = context.v_findOrCreateObject( ["remoteId" : NSNumber(longLong: user.userID)] )
                persistentUser.populate(fromSourceModel: user)

                let uniqueElements = [ "sequence"  : sequence, "user" : persistentUser ]
                let userSequenceContext: VSequenceLiker = context.v_findOrCreateObject( uniqueElements )
                userSequenceContext.sequenceId = self.sequenceID
                userSequenceContext.displayOrder = displayOrder++
                sequence.v_addObject( userSequenceContext, to: "likers" )
            }
            context.v_save()
            
            self.results =  self.fetchResults()
            completion()
        }
    }
    
    private func fetchResults() -> [VSequenceLiker] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VSequenceLiker.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                format: "sequenceId = %@",
                argumentArray: [ self.sequenceID ],
                paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
