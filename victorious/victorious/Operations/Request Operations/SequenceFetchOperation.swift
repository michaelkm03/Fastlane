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
    
    override func onResponse(response: SequenceFetchRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            let sequence: VSequence = context.findOrCreateObject([ "remoteId" : String(response.sequenceID) ])
            sequence.populate(fromSourceModel: response )
            context.saveChanges()
        }
    }
}