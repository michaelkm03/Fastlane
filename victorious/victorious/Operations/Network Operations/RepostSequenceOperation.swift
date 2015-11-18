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
    
    let dataStore = PersistentStore.backgroundContext
    
    init( nodeID: Int64 ) {
        super.init(request: RepostSequenceRequest(nodeID: nodeID) )
    }
    
    override func onStart() {
        let node = self.node
        guard !node.sequence.hasReposted.boolValue else {
            return
        }
        
        node.sequence.hasReposted = true
        node.sequence.repostCount += 1
        currentUser.repostedSequences.insert( node.sequence )
        dataStore.saveChanges()
        
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
        }
    }
    
    override func onError( error: NSError? ) {
        node.sequence.hasReposted = false
        node.sequence.repostCount -= 1
        currentUser.repostedSequences.remove(node.sequence )
        dataStore.saveChanges()
        
        dispatch_sync( dispatch_get_main_queue() ) {
            let params = [ VTrackingKeyErrorMessage : error?.localizedDescription ?? "" ]
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
        }
    }
    
    var currentUser: VUser {
        return dataStore.getObject( VUser.currentUser()!.identifier )!
    }
    
    var node: VNode {
        let uniqueElements = [ "remoteId" : Int(request.nodeID) ]
        return dataStore.findOrCreateObject( uniqueElements )
    }
}
