//
//  LogoutOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LogoutOperation: RequestOperation {
    
    let request = LogoutRequest()

    override init() {
        super.init()
        self.qualityOfService = .UserInitiated
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( result: LogoutRequest.ResultType, completion:()->() ) {
        
        guard let currentUserObjectID = VCurrentUser.user()?.objectID else {
            completion()
            return
        }
        
        VCurrentUser.clear()
        
        persistentStore.backgroundContext.v_performBlock() { context in
            
            guard let loggedOutUser: VUser = context.v_objectWithID( currentUserObjectID ) else {
                fatalError()
            }
            
            let conversations: [VConversation] = context.v_findObjects( [ "user" : loggedOutUser ])
            for object in conversations {
                context.deleteObject( object )
            }
            
            let pollResults: [VPollResult] = context.v_findObjects( [ "user" : loggedOutUser ])
            for object in pollResults {
                context.deleteObject( object )
            }
            
            context.v_save()
            completion()
        }
    }
}
