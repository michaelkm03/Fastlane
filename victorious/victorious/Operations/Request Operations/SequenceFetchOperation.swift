//
//  SequenceFetchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceFetchOperation: RequestOperation<SequenceFetchRequest> {
  
    private let persistentStore = PersistentStore()
    
    init( sequenceID: Int64) {
        super.init(request: SequenceFetchRequest(sequenceID: sequenceID) )
    }
    
    override func onComplete(result: SequenceFetchRequest.ResultType, completion:()->() ) {
        let sequence = result
        persistentStore.asyncFromBackground() { context in
            let persistentSequence: VSequence = context.findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ])
            persistentSequence.populate(fromSourceModel: sequence)
            context.saveChanges()
            completion()
        }
    }
}

class SequenceUserInterationsOperation: RequestOperation<UserInteractionsOnSequenceRequest> {
    
    private let persistentStore = PersistentStore()
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64, userID: Int64 ) {
        self.sequenceID = sequenceID
        super.init(request: UserInteractionsOnSequenceRequest(sequenceID: sequenceID, userID:userID) )
    }
    
    override func onComplete(result:UserInteractionsOnSequenceRequest.ResultType, completion: () -> ()) {
        persistentStore.asyncFromBackground() { context in
            let sequence: VSequence = context.findOrCreateObject([ "remoteId" : String(self.sequenceID) ])
            sequence.hasBeenRepostedByMainUser = result
            context.saveChanges()
            completion()
        }
    }
}
