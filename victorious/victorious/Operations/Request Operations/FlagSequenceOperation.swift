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
            
            // First, batch delete any pointers to remove the sequence from ALL streams
            let deletePointer = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            deletePointer.predicate = NSPredicate(format:"streamItem.remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deletePointer)
            
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
