//
//  LogoutOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LogoutOperation: RequestOperation<LogoutRequest> {
    
    let userIdentifier: AnyObject
    
    init( userIdentifier: AnyObject ) {
        self.userIdentifier = userIdentifier
        
        super.init( request: LogoutRequest() )
        
        qualityOfService = .UserInitiated
    }
    
    override func onResponse(result: LogoutRequest.ResultType) {
        
        let persistentStore = PersistentStore()
        guard let loggedOutUser: VUser = persistentStore.backgroundContext.getObject(self.userIdentifier) else {
            fatalError()
        }
        
        let conversations: [VConversation] = persistentStore.backgroundContext.findObjects( [ "user" : loggedOutUser ])
        for object in conversations {
            persistentStore.backgroundContext.destroy( object )
        }
        
        let pollResults: [VPollResult] = persistentStore.backgroundContext.findObjects( [ "user" : loggedOutUser ])
        for object in pollResults {
            persistentStore.backgroundContext.destroy( object )
        }
        
        persistentStore.backgroundContext.saveChanges()
    }
}
