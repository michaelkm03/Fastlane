//
//  SuggestedUsersRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct SuggestedUsersRequest: RequestType {
    public init() { }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/discover/suggested_users")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [SuggestedUser] {
        guard let suggestedUsersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let suggestedUsers = suggestedUsersJSON.flatMap { json -> SuggestedUser? in
            var userJson = json
            guard let validUser = User(json: userJson) else {
                return nil
            }
            for i in 0..<userJson["recent_sequences"].count {
                userJson["recent_sequences"][i][ "user" ] = userJson
            }
            let sequences = userJson["recent_sequences"].arrayValue.flatMap{ Sequence(json: $0) }
            return SuggestedUser(user: validUser, recentSequences: sequences)
        }
        return suggestedUsers
    }
}
