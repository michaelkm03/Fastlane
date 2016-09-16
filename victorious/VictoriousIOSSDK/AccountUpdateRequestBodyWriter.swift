//
//  AccountUpdateRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AccountUpdateRequestBodyWriter: NSObject, RequestBodyWriterType {
    struct Output {
        let fileURL: NSURL
        let contentType: String
    }
    
    let parameters: AccountUpdateParameters
    
    init(parameters: AccountUpdateParameters) {
        self.parameters = parameters
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    func write() throws -> Output {
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        
        // Write params for a password update
        if
            let currentPassword = parameters.passwordUpdate?.currentPassword,
            let newPassword = parameters.passwordUpdate?.newPassword
        {
            try writer.appendPlaintext(currentPassword, withFieldName: "current_password")
            try writer.appendPlaintext(newPassword, withFieldName: "new_password")
        }
        
        // Write params for a profile update
        if let name = parameters.profileUpdate?.displayName {
            try writer.appendPlaintext(name, withFieldName: "name")
        }
        if let location = parameters.profileUpdate?.location {
            try writer.appendPlaintext(location, withFieldName: "profile_location")
        }
        if let tagline = parameters.profileUpdate?.tagline {
            try writer.appendPlaintext(tagline, withFieldName: "profile_tagline")
        }
        //TODO: Write the username to update here
        
        if let profileImageURL = parameters.profileUpdate?.profileImageURL,
            let pathExtension = profileImageURL.pathExtension,
            let mimeType = profileImageURL.vsdk_mimeType {
                try writer.appendFileWithName("profile_image.\(pathExtension)",
                    contentType: mimeType,
                    fileURL: profileImageURL,
                    fieldName: "profile_image"
                )
        }
        
        try writer.finishWriting()
        
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader())
    }
}
