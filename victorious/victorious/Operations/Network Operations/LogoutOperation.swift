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
        
        let dataStore = PersistentStore.backgroundContext
        guard let loggedOutUser: VUser = dataStore.getObject(self.userIdentifier) else {
            fatalError()
        }
        
        let conversations: [VConversation] = dataStore.findObjects( [ "user" : loggedOutUser ])
        for object in conversations {
            dataStore.destroy( object )
        }
        
        let pollResults: [VPollResult] = dataStore.findObjects( [ "user" : loggedOutUser ])
        for object in pollResults {
            dataStore.destroy( object )
        }
        
        dataStore.saveChanges()
    }
}
