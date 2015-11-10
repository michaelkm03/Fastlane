//
//  SuggestedUsersRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct SuggestedUsersRequest: RequestType {
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/discover/suggested_users")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [SuggestedUser] {
        guard let suggestedUsersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let suggestedUsers = suggestedUsersJSON.flatMap ({ jsonValue -> SuggestedUser? in
            guard let validUser = User(json: jsonValue) else {
                return nil
            }
            return SuggestedUser (user: validUser,
                recentSequences: jsonValue["recent_sequences"].arrayValue.flatMap{ Sequence(json:$0) })
        })
        
        return suggestedUsers
    }
}
