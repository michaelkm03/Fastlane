//
//  UsernameAvailabilityRequest.swift
//  victorious
//
//  Created by Michael Sena on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UsernameAvailabilityRequest: RequestType {
    private let url: URL
    private let usernameToCheck: String
    
    private struct Constants {
        static let appIDMacro = "%%APP_ID%%"
        static let usernameMacro = "%%USERNAME%%"
    }
    
    public init?(apiPath: APIPath, usernameToCheck: String, appID: String) {
        var apiPath = apiPath
        apiPath.macroReplacements[Constants.appIDMacro] = appID
        apiPath.macroReplacements[Constants.usernameMacro] = usernameToCheck
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.usernameToCheck = usernameToCheck
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: self.url as URL)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> Bool {
        return responseJSON["payload"]["success"].boolValue
    }
}
