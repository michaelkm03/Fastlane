//
//  PasswordUpdate.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Input to a AccountUpdateRequest Used to update a user's password
public struct PasswordUpdate {
    public let username: String
    public let currentPassword: String
    public let newPassword: String
    
    public init(username: String, currentPassword: String, newPassword: String) {
        self.username = username
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}
