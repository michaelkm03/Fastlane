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
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let userID: Int
    
    init( userID: Int ) {
        self.userID = userID
        super.init()
        
        let remoteOperation = BlockUserRemoteOperation(userID: userID)
        remoteOperation.after(self).queue() { result, error in
            
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                self.trackingManager.trackEvent( VTrackingEventBlockUserDidFail, parameters: params )
                
            } else {
                self.trackingManager.trackEvent( VTrackingEventUserDidBlockUser )
            }
        }
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
            
            if let users: [VUser] = context.v_findObjects(["remoteId" : self.userID]) {
                for user in users {
                    user.isBlockedByMainUser = NSNumber(bool: true)
                }
            }
            
            context.v_save()
        }
    }
}

class BlockUserRemoteOperation: FetcherOperation, RequestOperation {
    
    let request: BlockUserRequest!
    
    init( userID: Int ) {
        self.request = BlockUserRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
