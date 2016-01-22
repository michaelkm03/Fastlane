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
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
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

class LoadStreamOperation: FetcherOperation {
    
    private let apiPath: String
    
    var result: VStream?
    
    init(apiPath: String, title: String) {
        self.apiPath = apiPath
    }
    
    override func main() {
        // Loading a stream is required before a stream UI can be shown, so we use main context
        self.persistentStore.mainContext.v_performBlockAndWait() { context in
            self.result = context.v_findOrCreateObject([ "apiPath" : self.apiPath ]) as? VStream
        }
    }
}
