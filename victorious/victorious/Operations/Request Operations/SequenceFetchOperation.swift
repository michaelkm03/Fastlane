//
//  SequenceFetchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceFetchOperation: RequestOperation {
    
    let request: SequenceFetchRequest
    
    var result: VSequence?
    
    init( sequenceID: String ) {
        self.request = SequenceFetchRequest(sequenceID: sequenceID)
        super.init()
        self.qualityOfService = .UserInitiated
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( sequence: SequenceFetchRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            let persistentSequence: VSequence = context.v_findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ])
            persistentSequence.populate(fromSourceModel: sequence)
            context.v_save()
            
            let persistentSequenceID = persistentSequence.objectID
            
            self.persistentStore.mainContext.v_performBlockAndWait { context in
                if let sequence = context.objectWithID(persistentSequenceID) as? VSequence {
                    self.result = sequence
                }
                completion()
            }
        }
    }
}