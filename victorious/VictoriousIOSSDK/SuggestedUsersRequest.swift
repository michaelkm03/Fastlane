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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [SuggestedUser], nextPage: SequenceLikersRequest?, previousPage: SequenceLikersRequest?) {
        guard let suggestedUsersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let users = suggestedUsersJSON.flatMap { User(json: $0) }
        
        var recentSequencesForAllUsers: [[Sequence]] = [[]]
        
        for eachUserJSON in suggestedUsersJSON {
            let eachUserRecentSequences = eachUserJSON["recent_sequences"].arrayValue
            let recentSequencesPerUser = eachUserRecentSequences.flatMap { Sequence(json: $0) }
            recentSequencesForAllUsers.append(recentSequencesPerUser)
        }
        
        let suggestedUsers = Array(Zip2Sequence(users, recentSequencesForAllUsers)).flatMap { SuggestedUser(user: $0, recentSequences: $1) }
        
        return (suggestedUsers, nil, nil)
    }
}
