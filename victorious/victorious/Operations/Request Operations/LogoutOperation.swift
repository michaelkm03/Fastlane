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
    
    let userIdentifier: AnyObject
    
    init( userIdentifier: AnyObject ) {
        self.userIdentifier = userIdentifier
        super.init()
        self.qualityOfService = .UserInitiated
    }
    
    override func main() {
        executeRequest( self.request, onComplete: self.onComplete )
    }
    
    private func onComplete( result: LogoutRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            guard let loggedOutUser: VUser = context.getObject(self.userIdentifier) else {
                fatalError()
            }
            
            let conversations: [VConversation] = context.findObjects( [ "user" : loggedOutUser ])
            for object in conversations {
                context.destroy( object )
            }
            
            let pollResults: [VPollResult] = context.findObjects( [ "user" : loggedOutUser ])
            for object in pollResults {
                context.destroy( object )
            }
            
            context.saveChanges()
            completion()
        }
    }
}
