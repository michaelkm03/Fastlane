//
//  BlockUserRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct BlockUserRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/user/block")!)
        request.vsdk_addURLEncodedFormPost(["user_id": userID])
        return request
    }
    
    private let userID: Int
    
    public init(userID: Int) {
        self.userID = userID
    }
}
