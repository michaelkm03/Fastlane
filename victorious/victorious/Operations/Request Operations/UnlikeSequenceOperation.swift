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
        let uniqueElements = [ "remoteId" : self.sequenceID ]
        persistentStore.backgroundContext.v_performBlock() { context in
            let sequence: VSequence = context.v_findOrCreateObject( uniqueElements )
            sequence.isLikedByMainUser = false
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.request )
    }
}
