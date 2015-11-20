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
    
    private let persistentStore = PersistentStore()
    
    init( nodeID: Int64 ) {
        super.init(request: RepostSequenceRequest(nodeID: nodeID) )
    }
    
    override func onStart() {
        // Peform optimistic changes before the request is executed
        persistentStore.syncFromBackground() { context in
            guard let user = VUser.currentUser() else {
                fatalError( "User must be logged in." )
            }
            let node:VNode = context.findOrCreateObject( [ "remoteId" : Int(self.request.nodeID) ] )
            node.sequence.hasReposted = true
            node.sequence.repostCount += 1
            user.repostedSequences.insert( node.sequence )
            context.saveChanges()
        }
    }
}
