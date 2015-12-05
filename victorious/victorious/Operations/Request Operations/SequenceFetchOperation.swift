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
    
    var currentRequest: SequenceFetchRequest
    
    init( sequenceID: Int64) {
        self.currentRequest = SequenceFetchRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( sequence: SequenceFetchRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            let persistentSequence: VSequence = context.findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ])
            persistentSequence.populate(fromSourceModel: sequence)
            context.saveChanges()
            completion()
        }
    }
}