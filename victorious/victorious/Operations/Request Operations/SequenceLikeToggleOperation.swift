//
//  SequenceLikeToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SequenceLikeToggleOperation: FetcherOperation {
    
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
                SequenceUnlikeOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
            }
            else {
                SequenceLikeOperation( sequenceID: sequence.remoteId ).rechainAfter(self).queue()
            }
        }
    }
}
