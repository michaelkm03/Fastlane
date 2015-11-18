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
    
    init( sequenceID: Int64) {
        super.init(request: SequenceFetchRequest(sequenceID: sequenceID) )
    }
    
    override func onResponse(response: SequenceFetchRequest.ResultType) {
        let dataStore = PersistentStore.backgroundContext
        let sequence: VSequence = dataStore.findOrCreateObject([ "remoteId" : String(response.sequenceID) ])
        sequence.populate(fromSourceModel: response )
        dataStore.saveChanges()
    }
}