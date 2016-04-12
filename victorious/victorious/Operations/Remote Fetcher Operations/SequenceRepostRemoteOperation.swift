//
//  SequenceRepostRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SequenceRepostRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    var request: RepostSequenceRequest!
    
    init( nodeID: Int ) {
        self.request = RepostSequenceRequest(nodeID: nodeID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    private func onComplete( sequence: RepostSequenceRequest.ResultType) {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
    }
    
    private func onError( error: NSError) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters: params )
    }
}
