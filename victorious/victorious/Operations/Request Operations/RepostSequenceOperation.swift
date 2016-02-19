//
//  RepostSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class RepostSequenceOperation: RequestOperation {
    
    private let nodeID: Int
    
    var request: RepostSequenceRequest
    
    init( nodeID: Int ) {
        self.nodeID = nodeID
        self.request = RepostSequenceRequest(nodeID: nodeID)
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        let didSucceed: Bool = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user = VCurrentUser.user(inManagedObjectContext: context) else {
                return false
            }
            let node:VNode = context.v_findOrCreateObject( [ "remoteId" : self.nodeID ] )
            node.sequence.hasReposted = true
            node.sequence.repostCount += 1
            user.v_addObject(node.sequence, to: "repostedSequences")
            
            context.v_save()
            return true
        }
        
        guard didSucceed else {
            return
        }
        
        // Then execute the request
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
