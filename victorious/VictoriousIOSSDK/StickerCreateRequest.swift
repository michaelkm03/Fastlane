//
//  StickerCreateRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class StickerCreateRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = formParams.vsdk_urlEncodedString().dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    private let url: NSURL
    private let formParams: NSDictionary
    
    public init?(apiPath: APIPath, formParams: [NSObject : AnyObject]) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.formParams = formParams
    }
}
