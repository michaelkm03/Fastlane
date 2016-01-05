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
    
    var request: SequenceUserInteractionsRequest
    
    private let sequenceID: String
    
    init( sequenceID: String, userID: Int64 ) {
        self.sequenceID = sequenceID
        self.request = SequenceUserInteractionsRequest(sequenceID: sequenceID, userID:userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
    
    private func onComplete( result: SequenceUserInteractionsRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            let sequence: VSequence = context.v_findOrCreateObject([ "remoteId" : String(self.sequenceID) ])
            sequence.hasBeenRepostedByMainUser = result
            context.v_save()
            completion()
        }
    }
}
