//
//  SequenceInteractionsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceUserInterationsOperation: FetcherOperation, RequestOperation {
    
    let request: SequenceUserInteractionsRequest!
    
    private let sequenceID: String
    
    init( sequenceID: String, userID: Int ) {
        self.sequenceID = sequenceID
        self.request = SequenceUserInteractionsRequest(sequenceID: sequenceID, userID:userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
    
    private func onComplete( result: SequenceUserInteractionsRequest.ResultType, completion:()->() ) {
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            let sequence: VSequence = context.v_findOrCreateObject([ "remoteId" : self.sequenceID ])
            sequence.hasBeenRepostedByMainUser = result
            context.v_save()
            completion()
        }
    }
}
