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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
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