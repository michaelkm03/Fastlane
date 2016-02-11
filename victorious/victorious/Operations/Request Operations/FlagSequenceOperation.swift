//
//  FlagSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagSequenceOperation: FetcherOperation {
    
    private let sequenceID: String
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: String ) {
        self.sequenceID = sequenceID
        super.init()
        
        let remoteOperation = FlagSequenceRemoteOperation(sequenceID: sequenceID)
        remoteOperation.queueAfter( self )
    }
    
    override func main() {
        self.flaggedContent.addRemoteId( sequenceID, toFlaggedItemsWithType: .StreamItem)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // First, batch delete any "pointer" models t
            let deleteStreamItemPointers = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            deleteStreamItemPointers.predicate = NSPredicate(format:"streamItem.remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteStreamItemPointers)
            
            let deleteLikers = NSFetchRequest(entityName: VSequenceLiker.v_entityName())
            deleteLikers.predicate = NSPredicate(format:"sequence.remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteLikers)
            
            // Then take care of the sequence itself
            let deleteSequence = NSFetchRequest(entityName: VSequence.v_entityName())
            deleteSequence.predicate = NSPredicate(format:"remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteSequence)
            
            context.v_saveAndBubbleToParentContext()
        }
    }
}

class FlagSequenceRemoteOperation: RequestOperation {
    
    let request: FlagSequenceRequest
    
    init( sequenceID: String ) {
        self.request = FlagSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
