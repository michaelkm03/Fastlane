//
//  DeletedSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteSequenceOperation: FetcherOperation {
    
    private let sequenceID: String
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: String ) {
        self.sequenceID = sequenceID
        super.init()
        
        let remoteOperation = DeleteSequenceRemoteOperation(sequenceID: sequenceID)
        remoteOperation.queueAfter( self )
    }
    
    override func main() {
        self.flaggedContent.addRemoteId( sequenceID, toFlaggedItemsWithType: .StreamItem)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let sequence: VSequence = context.v_findObjects([ "remoteId" : self.sequenceID ]).first else {
                return
            }
            context.deleteObject( sequence )
            context.v_save()
        }
        
        // For deletions, force a save to the main context to make sure changes are propagated
        // to calling code (a view controller)
        self.persistentStore.mainContext.v_performBlockAndWait() { context in
            context.v_save()
        }
    }
}

class DeleteSequenceRemoteOperation: RequestOperation {
    
    let request: FlagSequenceRequest
    
    init( sequenceID: String ) {
        self.request = FlagSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
