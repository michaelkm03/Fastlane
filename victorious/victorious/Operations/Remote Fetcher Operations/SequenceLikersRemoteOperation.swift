//
//  SequenceLikersRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class SequenceLikersRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
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
    
    private func onComplete( users: SequenceLikersRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart
            
            let sequence: VSequence = context.v_findOrCreateObject(["remoteId" : self.sequenceID ])
            for user in users {
                let persistentUser: VUser = context.v_findOrCreateObject( ["remoteId" : user.id ] )
                persistentUser.populate(fromSourceModel: user)
                
                let uniqueElements = [ "sequence": sequence, "user": persistentUser ]
                let userSequenceContext: VSequenceLiker = context.v_findOrCreateObject( uniqueElements )
                userSequenceContext.sequence = sequence
                userSequenceContext.user = persistentUser
                userSequenceContext.displayOrder = displayOrder
                displayOrder += 1
            }
            context.v_save()
        }
    }
}
