//
//  UserModel.swift
//  victorious
//
//  Created by Jarod Long on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension UserModel {
    // MARK: - Current user information
    
    var isCurrentUser: Bool {
        return id == VCurrentUser.user()?.remoteId.integerValue
    }
}
