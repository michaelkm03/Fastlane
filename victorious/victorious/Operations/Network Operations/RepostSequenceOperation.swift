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
        
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
        }
    }
    
    override func onError( error: NSError? ) {
        
        // Undo the optimistic changes made before the request was executed
        persistentStore.syncFromBackground() { context in
            guard let user = VUser.currentUser() else {
                fatalError( "User must be logged in." )
            }
            let node:VNode = context.findOrCreateObject( [ "remoteId" : Int(self.request.nodeID) ] )
            node.sequence.hasReposted = false
            node.sequence.repostCount -= 1
            user.repostedSequences.remove(node.sequence )
            context.saveChanges()
        }
        
        dispatch_sync( dispatch_get_main_queue() ) {
            let params = [ VTrackingKeyErrorMessage : error?.localizedDescription ?? "" ]
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
        }
    }
}
