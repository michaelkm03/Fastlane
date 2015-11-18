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
    
    init( sequenceID: Int64 ) {
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart() {
        super.onStart()
        
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
        }
        
        let persistentStore = PersistentStore()
        let uniqueElements = [ "remoteId" : Int(request.sequenceID) ]
        let sequence: VSequence = persistentStore.backgroundContext.findOrCreateObject( uniqueElements )
        sequence.isLikedByMainUser = false
        persistentStore.backgroundContext.saveChanges()
    }
}
