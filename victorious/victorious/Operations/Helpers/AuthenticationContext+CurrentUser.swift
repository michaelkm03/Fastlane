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
    
    init?( currentUser: VUser? ) {
        guard let currentUser = currentUser else {
            return nil
        }
        self.init( userID: currentUser.remoteId.integerValue, token: currentUser.token)
    }
}
