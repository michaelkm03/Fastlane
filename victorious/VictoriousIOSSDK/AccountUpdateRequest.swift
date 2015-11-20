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
public class AccountUpdateRequest: RequestType {
    
    public let profileUpdate: User.ProfileUpdate?
    public let passwordUpdate: User.PasswordUpdate?
    
    public private(set) var urlRequest = NSURLRequest()
    
    private var bodyTempFile: NSURL?
    
    public init?(passwordUpdate: User.PasswordUpdate) {
        self.passwordUpdate = passwordUpdate
        self.profileUpdate = nil
        do {
            self.urlRequest = try makeRequest()
        } catch {
            return nil
        }
    }
    
    public init?(profileUpdate: User.ProfileUpdate) {
        self.profileUpdate = profileUpdate
        self.passwordUpdate = nil
        do {
            self.urlRequest = try makeRequest()
        } catch {
            return nil
        }
    }
    
    deinit {
        if let bodyTempFile = bodyTempFile {
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFile)
        }
    }
    
    private func makeRequest() throws -> NSURLRequest {
        let bodyTempFile = self.tempFile()
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        
        // Write params for a password update
        if let passwordCurrent = passwordUpdate?.passwordCurrent,
            let passwordNew = passwordUpdate?.passwordNew {
                try writer.appendPlaintext(passwordCurrent, withFieldName: "current_password")
                try writer.appendPlaintext(passwordNew, withFieldName: "new_password")
        }
        
        // Write params for a profile update
        if let email = profileUpdate?.email {
            try writer.appendPlaintext(email, withFieldName: "email")
        }
        if let name = profileUpdate?.name {
            try writer.appendPlaintext(name, withFieldName: "name")
        }
        if let location = profileUpdate?.location {
            try writer.appendPlaintext(location, withFieldName: "profile_location")
        }
        if let profileImageURL = profileUpdate?.profileImageURL,
           let pathExtension = profileImageURL.pathExtension,
           let mimeType = profileImageURL.vsdk_mimeType {
            try writer.appendFileWithName("profile_image.\(pathExtension)", contentType: mimeType, fileURL: profileImageURL, fieldName: "profile_image")
        }
        
        try writer.finishWriting()
        self.bodyTempFile = bodyTempFile
        
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/account/update")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: bodyTempFile)
        return request
    }
    
    private func tempFile() -> NSURL {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User? {
        return User(json: responseJSON["payload"])
    }
}
