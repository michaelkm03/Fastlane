//
//  AuthenticationContext+CurrentUser.swift
//  victorious
//
//  Created by Patrick Lynch on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension AuthenticationContext {
    init?() {
        var user: VUser?
        dispatch_sync(dispatch_get_main_queue()) {
            user = VCurrentUser.user()
        }
        self.init(currentUser: user)
    }
    
    init?(currentUser: VUser?) {
        guard let currentUser = currentUser, let token = currentUser.token else {
            return nil
        }
        
        self.init(userID: currentUser.remoteId.integerValue, token: token)
    }
}
