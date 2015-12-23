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
        persistentStore.backgroundContext.v_performBlock() { context in
            let uniqueElements = [ "remoteId" : self.sequenceID ]
            let sequences: [VSequence] = context.v_findObjects( uniqueElements )
            for sequence in sequences {
                sequence.isLikedByMainUser = true
            }
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.request )
    }
}
