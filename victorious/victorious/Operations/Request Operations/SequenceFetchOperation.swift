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
    
    private(set) var sequence: VSequence?
    
    init( sequenceID: Int64) {
        self.request = SequenceFetchRequest(sequenceID: sequenceID)
        super.init()
        self.qualityOfService = .UserInitiated
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( sequence: SequenceFetchRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            let persistentSequence: VSequence = context.v_findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ])
            persistentSequence.populate(fromSourceModel: sequence)
            context.v_save()
            
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                self.sequence = context.v_findObjects([ "remoteId" : String(sequence.sequenceID) ]).first
                completion()
            }
        }
    }
}
