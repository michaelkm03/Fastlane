//
//  AuthenticationContext+CurrentUser.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

extension AuthenticationContext {
    init?( currentUser: VUser? ) {
        guard let currentUser = currentUser else {
            return nil
        }
        self.init( userID: currentUser.remoteId.longLongValue, token: currentUser.token)
    }
}
