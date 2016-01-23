//
//  NSMutableURLRequest+UploadManager.swift
//  victorious
//
//  Created by Josh Hinman on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension NSMutableURLRequest {
    
    func v_setAuthorizationHeader(persistentStore persistentStore: PersistentStoreType) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        
        let authenticationContext = persistentStore.mainContext.v_performBlockAndWait() { _ in
            return AuthenticationContext(currentUser: VCurrentUser.user())
        }
        
        if let authenticationContext = authenticationContext {
            self.vsdk_setAuthorizationHeader(requestContext: requestContext, authenticationContext: authenticationContext)
        } else {
            self.vsdk_setAuthorizationHeader(requestContext: requestContext)
        }
    }
}