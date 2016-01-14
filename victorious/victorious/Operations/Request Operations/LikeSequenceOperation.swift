//
//  LikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LikeSequenceOperation: RequestOperation {
    
    let request: LikeSequenceRequest
    
    private let sequenceID: String
    
    init( sequenceID: String ){
        self.request = LikeSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }

    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let sequence: VSequence = context.v_findObjects(  [ "remoteId" : self.sequenceID ] ).first else {
                    return
            }
            
            sequence.isLikedByMainUser = true
            
            let uniqueElements = [ "sequence"  : sequence, "user" : currentUser ]
            let sequenceLiker: VSequenceLiker = context.v_findOrCreateObject(uniqueElements)
            sequenceLiker.sequence = sequence
            sequenceLiker.user = currentUser
            sequenceLiker.displayOrder = 0
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
