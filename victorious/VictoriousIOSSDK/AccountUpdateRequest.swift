//
//  AccountUpdateRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension User {
    
    /// Input to a AccountUpdateRequest Used to update a user's profile
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
}

/// Updates the user's profile information. All properties are optional.
/// Set any property to a non-nil value to update that field. All nil
/// properties will not be touched (e.g. setting "email" to nil will
/// retain the user's current email address).
public struct AccountUpdateRequest: RequestType {
    
    public let profileUpdate: User.ProfileUpdate?
    public let passwordUpdate: User.PasswordUpdate?
    public let urlRequest: NSURLRequest
    
    private let bodyWriter = RequestBodyWriter()
    
    public init?(passwordUpdate: User.PasswordUpdate) {
        self.init( passwordUpdate:passwordUpdate, profileUpdate:nil )
    }
    
    public init?(profileUpdate: User.ProfileUpdate) {
        self.init( passwordUpdate: nil, profileUpdate:profileUpdate )
    }
    
    public init?(passwordUpdate: User.PasswordUpdate?, profileUpdate: User.ProfileUpdate? ) {
        self.profileUpdate = profileUpdate
        self.passwordUpdate = nil
        do {
            let bodyTempFileURL = try bodyWriter.write(profileUpdate, passwordUpdate: passwordUpdate)
            
            let request = NSMutableURLRequest(URL: NSURL(string: "/api/account/update")!)
            request.HTTPMethod = "POST"
            request.HTTPBodyStream = NSInputStream(URL: bodyTempFileURL)
            self.urlRequest = request
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User {
        guard let user = User(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return user
    }
}
