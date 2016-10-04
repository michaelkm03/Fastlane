//
//  EndVIPEventRequest.swift
//  victorious
//
//  Created by Vincent Ho on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct EndVIPEventRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        return request
    }
}
