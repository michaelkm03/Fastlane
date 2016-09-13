//
//  UnreadNotificationsCountRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UnreadNotificationsCountRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
//    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [UserModel] {
//        guard let json = responseJSON["payload"]["users"].array else {
//            throw ResponseParsingError()
//        }
//        
//        return json.flatMap { User(json: $0) }
//    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Int {
        guard let count = responseJSON["payload"]["unread_count"].int else {
            throw ResponseParsingError()
        }
        
        return count
    }
}
