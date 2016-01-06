//
//  FriendFindByEmailRequest.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public class FriendFindByEmailRequest: RequestType {
    
    private let sha256Emails: [String]
    
    public init( emails: [String] ) {
        self.sha256Emails = emails.map{ vsdk_sha256($0) }
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/friend/find_by_email")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "emails": sha256Emails.joinWithSeparator(",")]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        let foundUsersJSON = responseJSON["payload"].arrayValue
        return foundUsersJSON.flatMap({ return User(json: $0) })
    }
    
}
