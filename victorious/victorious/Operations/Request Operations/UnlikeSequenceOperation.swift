//
//  UnlikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnlikeSequenceOperation: RequestOperation {
    
    let request: UnlikeSequenceRequest
    
    private let sequenceID: String
    
    init( sequenceID: String ){
        self.request = UnlikeSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            sequence.isLikedByMainUser = false
            sequence.v_removeObject( currentUser, from: "likers" )
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
