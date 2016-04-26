//
//  MediaUploadCreateRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct MediaUploadCreateRequest: RequestType {
    
    public let injectedBaseURL: NSURL
    
    public init(baseURL: NSURL) {
        self.injectedBaseURL = baseURL
    }
    
    public var baseURL: NSURL? {
        return injectedBaseURL
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/mediaupload/create", relativeToURL: baseURL)!)
        request.HTTPMethod = "POST"
        
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let mediaUploadSequenceID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return mediaUploadSequenceID
    }
}
