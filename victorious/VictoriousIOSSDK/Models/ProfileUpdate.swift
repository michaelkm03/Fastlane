//
//  File.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Input to a AccountUpdateRequest Used to update a user's profile.
/// All properties are optional.
/// Set any property to a non-nil value to update that field. All nil
/// properties will not be touched (e.g. setting "email" to nil will
/// retain the user's current email address).
public struct ProfileUpdate {
    public let email: String?
    public let name: String?
    public let location: String?
    public let tagline: String?
    
    /// To update the user's profile image, set this property to
    /// a file URL pointing to a new profile image on disk
    public let profileImageURL: NSURL?
    
    public init( email: String?, name: String?, location: String?, tagline: String?, profileImageURL: NSURL? ) {
        self.email = email
        self.name = name
        self.location = location
        self.tagline = tagline
        self.profileImageURL = profileImageURL
    }
}
