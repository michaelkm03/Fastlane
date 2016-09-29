//
//  AccountUpdateRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

struct AccountUpdateParameters {
    let profileUpdate: ProfileUpdate?
    let passwordUpdate: PasswordUpdate?
}

/// Updates the user's profile and/or password information
public struct AccountUpdateRequest: RequestType {
    
    public let profileUpdate: ProfileUpdate?
    public let passwordUpdate: PasswordUpdate?
    
    private let requestBodyWriter: AccountUpdateRequestBodyWriter
    private let requestBody: AccountUpdateRequestBodyWriter.Output
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: URL(string: "/api/account/update")!)
        request.httpMethod = "POST"
        request.httpBodyStream = InputStream(url: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?(passwordUpdate: PasswordUpdate) {
        self.init( passwordUpdate: passwordUpdate, profileUpdate: nil )
    }
    
    public init?(profileUpdate: ProfileUpdate) {
        self.init( passwordUpdate: nil, profileUpdate: profileUpdate )
    }
    
    public init?(passwordUpdate: PasswordUpdate?, profileUpdate: ProfileUpdate? ) {
        self.profileUpdate = profileUpdate
        self.passwordUpdate = nil
        do {
            let parameters = AccountUpdateParameters(
                profileUpdate: profileUpdate,
                passwordUpdate: passwordUpdate
            )
            requestBodyWriter = AccountUpdateRequestBodyWriter(parameters: parameters)
            requestBody = try requestBodyWriter.write()
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> User {
        requestBodyWriter.removeBodyTempFile()
        
        guard let user = User(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return user
    }
}
