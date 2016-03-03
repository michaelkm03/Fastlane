//
//  BlockUserRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class BlockUserRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: BlockUserRequest!
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    init( userID: Int ) {
        request = BlockUserRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    private func onComplete( sequence: BlockUserRequest.ResultType, completion:()->() ) {
        self.trackingManager.trackEvent( VTrackingEventUserDidBlockUser )
        completion()
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        self.trackingManager.trackEvent( VTrackingEventBlockUserDidFail, parameters: params )
        completion()
    }
}