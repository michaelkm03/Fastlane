//
//  NSMutableURLRequest+UploadManager.swift
//  victorious
//
//  Created by Josh Hinman on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension URLRequest {
    mutating func v_setAuthorizationHeader() {
        let requestContext = RequestContext()
        
        if let authenticationContext = AuthenticationContext() {
            vsdk_setAuthorizationHeader(requestContext: requestContext, authenticationContext: authenticationContext)
        }
        else {
            vsdk_setAuthorizationHeader(requestContext: requestContext)
        }
    }
}
