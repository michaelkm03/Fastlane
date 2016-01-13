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
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            let uniqueElements = [ "remoteId" : self.sequenceID ]
            let sequences: [VSequence] = context.v_findObjects( uniqueElements )
            for sequence in sequences {
                sequence.isLikedByMainUser = true
                currentUser.v_addObject( sequence, to: "likedSequences" )
            }
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
