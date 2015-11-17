//
//  LikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LikeSequenceOperation: RequestOperation<LikeSequenceRequest> {
    
    init( sequenceID: Int64 ) {
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart() {
        super.onStart()
        
        let dataStore = PersistentStore.backgroundContext
        let uniqueElements = [ "remoteId" : Int(request.sequenceID) ]
        let sequence: VSequence = dataStore.findOrCreateObject( uniqueElements )
        sequence.isLikedByMainUser = true
        dataStore.saveChanges()
    }
}

class UnlikeSequenceOperation: RequestOperation<LikeSequenceRequest> {
    
    init( sequenceID: Int64 ) {
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart() {
        super.onStart()
        
        let dataStore = PersistentStore.backgroundContext
        let uniqueElements = [ "remoteId" : Int(request.sequenceID) ]
        let sequence: VSequence = dataStore.findOrCreateObject( uniqueElements )
        sequence.isLikedByMainUser = true
        dataStore.saveChanges()
    }
}
