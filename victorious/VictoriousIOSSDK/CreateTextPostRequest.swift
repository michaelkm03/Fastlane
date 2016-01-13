//
//  CreateTextPostRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Text post background should either be a background color or a media URL
public enum TextPostBackground {
    case BackgoundColor(UIColor)
    case BackgroundImage(NSURL)
}

public struct TextPostParameters {
    let content: String
    let background: TextPostBackground
    
    public init(content: String, background: TextPostBackground) {
        self.content = content
        self.background = background
    }
}

public struct CreateTextPostRequest: RequestType {
    
    public init?(parameters: TextPostParameters) {
        return nil
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "")!)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        return ""
    }
}
