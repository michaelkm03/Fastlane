//
//  UnblockUserRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UnblockUserRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/user/unblock")!)
        request.vsdk_addURLEncodedFormPost(["user_id": userID])
        return request
    }
    
    private let userID: Int
    
    public init(userID: Int) {
        self.userID = userID
    }
}
