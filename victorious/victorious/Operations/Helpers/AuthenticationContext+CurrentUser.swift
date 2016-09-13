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
        guard
            let token = VCurrentUser.token,
            let id = VCurrentUser.user?.id
        else {
            return nil
        }
        
        self.init(userID: id, token: token)
    }
}
