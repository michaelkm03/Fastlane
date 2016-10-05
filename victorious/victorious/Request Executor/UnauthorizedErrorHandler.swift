//
//  UnauthorizedErrorHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 2/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Catches 401 errors and logs out the current user to force a login, i.e. reauthorization.
class UnauthorizedErrorHandler: RequestErrorHandler {
    
    func handle(_ error: NSError, with request: URLRequest? = nil) -> Bool {
        if error.code == 401 && VCurrentUser.user != nil {
            Log.warning("UnauthorizedErrorHandler received 401 with error: \(error) for request -> \(request)")
            
            LogoutOperation().queue()
            return true
        }
        return false
    }
}
