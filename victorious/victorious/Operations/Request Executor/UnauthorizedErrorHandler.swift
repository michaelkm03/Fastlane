//
//  UnauthorizedErrorHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 2/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Catches 401 errors and logs out the current user to force a login, i.e. reauthorization.
class UnauthorizedErrorHandler: RequestErrorHandler {
    
    func handleError(error: NSError) -> Bool {
        if error.code == 401 && VCurrentUser.user() != nil {
//            LogoutOperation().queue()
            return true
        }
        return false
    }
}
