//
//  ToggleLikeSequenceOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ToggleLikeSequenceOperation: FetcherOperation {
    
    private let sequenceObjectId: NSManagedObjectID
    
    init(sequenceObjectId: NSManagedObjectID) {
        self.sequenceObjectId = sequenceObjectId
        super.init()
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            if let sequence = context.objectWithID(self.sequenceObjectId) as? VSequence {
                if sequence.isLikedByMainUser.boolValue {
                    UnlikeSequenceOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
                }
                else {
                    LikeSequenceOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
                }
            }
        }
    }
}
