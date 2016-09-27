//
//  LogoutRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct LogoutRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(url: NSURL(string: "/api/logout")! as URL)
    }
}
