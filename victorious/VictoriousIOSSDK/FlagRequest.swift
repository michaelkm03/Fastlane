//
//  FlagRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FlagRequest: RequestType {
    public init(sequenceID: Int64) {
        
    }
    
    public init(commentID: Int64) {
        
    }
    
    public init (messageID: Int64) {
        
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "haha")!)
    }
}
