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
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequenceID: String) {
        self.sequenceID = sequenceID
        
        super.init()
        
        // Before, confirm with an alert
        FlagSequenceAlertOperation(originViewController: originViewController, dependencyManager: dependencyManager).before(self).queue()
        
        // After, fire and forget the remote request
        FlagSequenceRequestOperation(sequenceID: sequenceID).after(self).queue()
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            cancel()
            return
        }
        
        self.flaggedContent.addRemoteId( sequenceID, toFlaggedItemsWithType: .StreamItem)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // Delete any "pointer" (a.k.a. "join table") models to sever relationships
            let deleteStreamItemPointersRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            deleteStreamItemPointersRequest.predicate = NSPredicate(format:"streamItem.remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteStreamItemPointersRequest)
            
            let deleteLikersRequest = NSFetchRequest(entityName: VSequenceLiker.v_entityName())
            deleteLikersRequest.predicate = NSPredicate(format:"sequence.remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteLikersRequest)
            
            // Then take care of the sequence itself
            let deleteSequenceRequest = NSFetchRequest(entityName: VSequence.v_entityName())
            deleteSequenceRequest.predicate = NSPredicate(format:"remoteId == %@", self.sequenceID)
            context.v_deleteObjects(deleteSequenceRequest)
            
            context.v_saveAndBubbleToParentContext()
        }
    }
}

class FlagSequenceRequestOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: FlagSequenceRequest!
    
    init( sequenceID: String ) {
        self.request = FlagSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}