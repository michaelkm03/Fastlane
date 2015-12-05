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
    
    var currentRequest: UnlikeSequenceRequest
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64 ){
        self.currentRequest = UnlikeSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        let uniqueElements = [ "remoteId" : NSNumber( longLong: self.sequenceID) ]
        persistentStore.asyncFromBackground() { context in
            let sequence: VSequence = context.findOrCreateObject( uniqueElements )
            sequence.isLikedByMainUser = false
            context.saveChanges()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.currentRequest )
    }
}
