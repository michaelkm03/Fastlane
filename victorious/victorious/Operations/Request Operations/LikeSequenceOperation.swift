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
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64 ){
        self.request = LikeSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }

    override func main() {
        
        // Make data change optimistically before executing the request
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : NSNumber( longLong: self.sequenceID) ]
            let sequences: [VSequence] = context.findObjects( uniqueElements )
            for sequence in sequences {
                sequence.isLikedByMainUser = true
            }
            context.saveChanges()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.request )
    }
}
