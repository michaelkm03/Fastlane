//
//  UserInfoRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UserInfoRequest: RequestType {
    
    let userID: Int64
    
    public init( userID: Int64 ) {
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string:"/api/userinfo/fetch")!.URLByAppendingPathComponent( String(self.userID) )
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User {
        let results = responseJSON["payload"].arrayValue.flatMap({ User(json: $0) })
         if let user = results.first {
            return user
        }
        throw ResponseParsingError()
    }
}
