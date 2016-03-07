//
//  RepostSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class RepostSequenceOperation: FetcherOperation {
    
    private let sequenceID: String
    
    init( sequenceID: String ) {
        self.sequenceID = sequenceID
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        let didSucceed: Bool = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user = VCurrentUser.user(inManagedObjectContext: context) else {
                return false
            }
            let sequence:VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            guard let node = sequence.firstNode(), let nodeID = node.remoteId?.integerValue else {
                return false
            }
            sequence.hasReposted = true
            sequence.repostCount += 1
            user.v_addObject(sequence, to: "repostedSequences")
            
            context.v_save()
            
            RepostSequenceRemoteOperation(nodeID: nodeID).after(self).queue()
            return true
        }
        
        guard didSucceed else {
            return
        }
    }
}


class RepostSequenceRemoteOperation: FetcherOperation, RequestOperation {
    
    var request: RepostSequenceRequest!
    
    init( nodeID: Int ) {
        self.request = RepostSequenceRequest(nodeID: nodeID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    private func onComplete( sequence: RepostSequenceRequest.ResultType, completion:()->() ) {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
        completion()
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
        completion()
    }
}
