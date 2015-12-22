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
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let currentUser = VUser.currentUser(inManagedObjectContext: context) else {
                return
            }
            
            let uniqueElements = [ "remoteId" : String(self.sequenceID) ]
            let sequences: [VSequence] = context.v_findObjects( uniqueElements )
            for sequence in sequences {
                sequence.isLikedByMainUser = true
                currentUser.v_addObject( sequence, to: "likedSequences" )
            }
            context.v_save()
        }
        
        // Now execute the request fire-and-forget style
        executeRequest( self.request )
    }
}
