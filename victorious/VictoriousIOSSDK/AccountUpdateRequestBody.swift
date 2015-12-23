//
//  RequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Utility used for creating large HTTP request POST bodies in temporary files.
/// This is particularly useful for large bodies, such as those that contain images or other media.
class AccountUpdateRequestBody: NSObject {
    
    struct Output {
        let fileURL: NSURL
        let contentType: String
    }
    
    private var bodyTempFile: NSURL = {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString)
    }()
    
    deinit {
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFile)
    }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write( profileUpdate: ProfileUpdate?, passwordUpdate: PasswordUpdate?) throws -> Output {
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
        if let tagline = profileUpdate?.tagline {
            try writer.appendPlaintext(tagline, withFieldName: "profile_tagline")
        }
        
        if let profileImageURL = profileUpdate?.profileImageURL,
            let pathExtension = profileImageURL.pathExtension,
            let mimeType = profileImageURL.vsdk_mimeType {
                try writer.appendFileWithName("profile_image.\(pathExtension)",
                    contentType: mimeType,
                    fileURL: profileImageURL,
                    fieldName: "profile_image"
                )
        }
        
        try writer.finishWriting()
        
        return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}