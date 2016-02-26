//
//  BlockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class BlockUserOperation: FetcherOperation {
    
    private let userID: Int
    
    init( userID: Int ) {
        self.userID = userID
        super.init()
        
        let remoteOperation = BlockUserRemoteOperation(userID: userID)
        remoteOperation.queueAfter( self )
    }
    
    override func main() {        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let deleteSequenceRequest = NSFetchRequest(entityName: VSequence.v_entityName())
            deleteSequenceRequest.predicate = NSPredicate(format:"user.remoteId == %i", self.userID)
            
            // Delete any "pointer" (a.k.a. "join table") models to sever relationships
            if let sequences: [VSequence] = context.v_executeFetchRequest(deleteSequenceRequest) {
                let deleteStreamItemPointersRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
                var predicates = [NSPredicate]()
                for sequence in sequences {
                    let predicate = NSPredicate(format: "streamItem.remoteId == %@", sequence.remoteId)
                    predicates.append(predicate)
                }
                deleteStreamItemPointersRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                context.v_deleteObjects(deleteStreamItemPointersRequest)
            }
            
            context.v_deleteObjects(deleteSequenceRequest)
            
            context.v_saveAndBubbleToParentContext()
        }
    }
}

class BlockUserRemoteOperation: RequestOperation {
    
    let request: BlockUserRequest
    
    init( userID: Int ) {
        self.request = BlockUserRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
