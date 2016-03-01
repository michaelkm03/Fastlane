//
//  UnblockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnblockUserOperation: FetcherOperation {
    
    private let userID: Int
        
    init( userID: Int ) {
        self.userID = userID
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            self.cancel()
            return
        }
        
        UnblockUserRemoteOperation(userID: userID).after(self).queue()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            if let users: [VUser] = context.v_findObjects(["remoteId" : self.userID]) {
                for user in users {
                    user.isBlockedByMainUser = NSNumber(bool: false)
                }
            }
            
            context.v_save()
        }
    }
}

class UnblockUserRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UnblockUserRequest!
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    init( userID: Int ) {
        request = UnblockUserRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    private func onComplete( sequence: RepostSequenceRequest.ResultType, completion:()->() ) {
        self.trackingManager.trackEvent( VTrackingEventUserDidUnblockUser )
        completion()
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        self.trackingManager.trackEvent( VTrackingEventUnblockUserDidFail, parameters: params )
        completion()
    }
}
