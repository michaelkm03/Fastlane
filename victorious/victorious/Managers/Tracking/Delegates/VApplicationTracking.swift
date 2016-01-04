//
//  VApplicationTracking.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

public extension VApplicationTracking {
    
    /*public func request( url url: NSURL ) -> NSURLRequest? {
        let mutableRequest = NSMutableURLRequest(URL: url)
        mutableRequest.HTTPBody = nil
        mutableRequest.HTTPMethod = "GET"
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        
        let persistentStore: PersistentStoreType = MainPersistentStore()
        let authenticationContext = persistentStore.mainContext.v_performBlockAndWait() { context in
            return AuthenticationContext(currentUser: VUser.currentUser())
        }
        
        if let requestURLString = mutableRequest.URL?.absoluteString {
            mutableRequest.URL = NSURL(string: requestURLString, relativeToURL: baseURL)
        }
        if let authenticationContext = authenticationContext {
            mutableRequest.vsdk_setAuthorizationHeader(requestContext: requestContext, authenticationContext: authenticationContext)
        } else {
            mutableRequest.vsdk_setAuthorizationHeader(requestContext: requestContext)
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }*/
}
