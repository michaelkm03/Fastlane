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
    
    init( parameters: AccountUpdateParameters ) {
        self.parameters = parameters
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    func write() throws -> Output {
        
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        
        // Write params for a password update
        if let passwordCurrent = parameters.passwordUpdate?.passwordCurrent,
            let passwordNew = parameters.passwordUpdate?.passwordNew {
                try writer.appendPlaintext(passwordCurrent, withFieldName: "current_password")
                try writer.appendPlaintext(passwordNew, withFieldName: "new_password")
        }
        
        // Write params for a profile update
        if let email = parameters.profileUpdate?.email {
            try writer.appendPlaintext(email, withFieldName: "email")
        }
        if let name = parameters.profileUpdate?.name {
            try writer.appendPlaintext(name, withFieldName: "name")
        }
        if let location = parameters.profileUpdate?.location {
            try writer.appendPlaintext(location, withFieldName: "profile_location")
        }
        if let tagline = parameters.profileUpdate?.tagline {
            try writer.appendPlaintext(tagline, withFieldName: "profile_tagline")
        }
        
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
        
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
