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
    func v_setAuthorizationHeader() {
        let requestContext = RequestContext()
        
        if let authenticationContext = AuthenticationContext() {
            self.vsdk_setAuthorizationHeader(requestContext: requestContext, authenticationContext: authenticationContext)
        } else {
            self.vsdk_setAuthorizationHeader(requestContext: requestContext)
        }
    }
}
