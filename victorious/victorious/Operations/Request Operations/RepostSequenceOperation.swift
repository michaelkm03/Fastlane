//
//  RepostSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class RepostSequenceOperation: RequestOperation<RepostSequenceRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let nodeID: Int64
    
    init( nodeID: Int64 ) {
        self.nodeID = nodeID
        super.init(request: RepostSequenceRequest(nodeID: nodeID) )
    }
    
    override func onStart( completion:()->() ) {
        // Peform optimistic changes before the request is executed
        persistentStore.asyncFromBackground() { context in
            guard let user = VUser.currentUser() else {
                fatalError( "User must be logged in." )
            }
            let node:VNode = context.findOrCreateObject( [ "remoteId" : Int(self.nodeID) ] )
            node.sequence.hasReposted = true
            node.sequence.repostCount += 1
            user.repostedSequences.insert( node.sequence )
            context.saveChanges()
            
            completion()
        }
    }
}
