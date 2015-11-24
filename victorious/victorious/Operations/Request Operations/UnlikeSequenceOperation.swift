//
//  UnlikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnlikeSequenceOperation: RequestOperation<LikeSequenceRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64 ) {
        self.sequenceID = sequenceID
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart( completion:()->() ) {
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
        
        let uniqueElements = [ "remoteId" : NSNumber( longLong: self.sequenceID) ]
        persistentStore.asyncFromBackground() { context in
            let sequence: VSequence = context.findOrCreateObject( uniqueElements )
            sequence.isLikedByMainUser = false
            context.saveChanges()
            completion()
        }
    }
}
