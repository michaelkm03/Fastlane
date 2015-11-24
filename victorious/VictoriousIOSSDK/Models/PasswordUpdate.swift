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
    public let email: String
    public let passwordCurrent: String
    public let passwordNew: String
    
    public init( email: String, passwordCurrent: String, passwordNew: String ) {
        self.email = email
        self.passwordCurrent = passwordCurrent
        self.passwordNew = passwordNew
    }
}
