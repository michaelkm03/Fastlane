//
//  UnlikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnlikeSequenceOperation: FetcherOperation {
    
    private let sequenceID: String
    
    init( sequenceID: String ){
        self.sequenceID = sequenceID
        super.init()
        
        UnlikeSequenceRequestOperation(sequenceID: sequenceID).after(self).queue()
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let sequence: VSequence = context.v_findObjects( [ "remoteId" : self.sequenceID ] ).first else {
                    return
            }
            
            sequence.isLikedByMainUser = false
            sequence.likeCount -= 1
            
            let uniqueElements = [ "sequence"  : sequence, "user" : currentUser ]
            context.v_deleteObjectsWithEntityName(VSequenceLiker.v_entityName(), queryDictionary: uniqueElements)
            
            context.v_save()
        }
    }
}

class UnlikeSequenceRequestOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UnlikeSequenceRequest!
    
    init( sequenceID: String ){
        self.request = UnlikeSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        // Execute the request fire-and-forget style
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
