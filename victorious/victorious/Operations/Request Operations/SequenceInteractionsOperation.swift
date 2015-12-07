//
//  SequenceInteractionsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceUserInterationsOperation: RequestOperation {
    
    var currentRequest: SequenceUserInteractionsRequest
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64, userID: Int64 ) {
        self.sequenceID = sequenceID
        self.currentRequest = SequenceUserInteractionsRequest(sequenceID: sequenceID, userID:userID)
    }
    
    override func main() {
        executeRequest( self.currentRequest )
    }
    
    private func onComplete( result: SequenceUserInteractionsRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            let sequence: VSequence = context.findOrCreateObject([ "remoteId" : String(self.sequenceID) ])
            sequence.hasBeenRepostedByMainUser = result
            context.saveChanges()
            completion()
        }
    }
}
