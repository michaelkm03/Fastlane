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
    
    var currentRequest: LikeSequenceRequest
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64 ){
        self.currentRequest = LikeSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }

    override func main() {
        
        // Make data change optimistically before executing the request
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : NSNumber( longLong: self.sequenceID) ]
            let sequence: VSequence = context.findOrCreateObject( uniqueElements )
            sequence.isLikedByMainUser = true
            context.saveChanges()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.currentRequest )
    }
}
