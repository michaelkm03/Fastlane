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
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            guard let sequence = context.objectWithID(self.sequenceObjectId) as? VSequence else {
                return
            }
            if sequence.isLikedByMainUser.boolValue {
                UnlikeSequenceOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
            }
            else {
                LikeSequenceOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
            }
        }
    }
}
